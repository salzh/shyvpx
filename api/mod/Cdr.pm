=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut
use POSIX qw(strftime);
use MIME::Base64;

sub getcdr () {
	local %post_add = ();
	%response       = ();   
	%domain         = &get_domain();


	local %params = (
		uuid => {type => 'string', maxlen => 36, notnull => 0, default => ''},
		direction => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		caller_id_number => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		destination_number => {type => 'string', maxlen => 50, notnull => 0, default => ''},        
		start_stamp => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		end_stamp => {type => 'string', maxlen => 50, notnull => 0, default =>''},
		caller_id_name => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		page => {type => 'int', maxlen => 50, notnull => 0, default => 0},
		limit => {type => 'int', maxlen => 50, notnull => 0, default => 100},
		missed => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
		cc_queue => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		queue_extension => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		cc_result => {type => 'string', maxlen => 50, notnull => 0, default => ''}
	);


	if (!$domain{name}) {
		&print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}


	for $k (keys %params) {
		$tmpval   = '';
		if (&getvalue(\$tmpval, $k, $params{$k})) {
			$post_add{$k} = $tmpval;
		} else {
			$response{stat}	    = "fail";
			$response{message}	= $k. &_(" not valid");
		}
	}

	%queues = &database_select_as_hash(
		"select
		queue_name,queue_extension,call_center_queue_uuid
		from
		v_call_center_queues
		where
		domain_uuid='$domain{uuid}'",
		"queue_extension,call_center_queue_uuid");

	$condition = "domain_uuid='$domain{uuid}'";
	for (keys %post_add) {
		next if  !$_ || $post_add{$_} eq '' || $_ eq 'page' || $_ eq 'limit';
		$condition .= ' AND ' if $condition;
		if ($_ eq 'start_stamp') {
			$condition .= "start_stamp >= '$post_add{start_stamp}'";
		} elsif ($_ eq 'end_stamp') {
			$condition .= "end_stamp <= '$post_add{end_stamp}'";
		} elsif ($_ eq 'missed' ) {
			if ($post_add{missed} eq 'true') {
				$condition .= "billsec=0"
			} else {
				$condition .= " 1=1 ";
			}
		} elsif ($_ eq 'call_result' ) {
			if ($post_add{call_result} eq 'answered') {
				$condition .= "(answer_stamp is not null and bridge_uuid is not null)";
			} elsif ($post_add{call_result} eq 'voicemail') {
				$condition .= "(answer_stamp is not null and bridge_uuid is null)";
			} elsif ($post_add{call_result} eq 'missed' || $post_add{call_result} eq 'cancelled') {
				$condition .= " (answer_stamp is not null and bridge_uuid is null) ";
			} elsif ($post_add{call_result} eq 'failed') {
				$condition .= "(answer_stamp is null and bridge_uuid is null and billsec = 0 and sip_hangup_disposition = 'send_refuse')";
			} 
		} else {
			if ($_ eq 'cc_queue' ) {
				if (lc($post_add{$_}) eq 'null' or lc($post_add{$_}) eq 'not null') {
					$condition .= "$_ IS $post_add{$_}"; next;
				} elsif (index($post_add{$_}, '@') == -1) {
					$post_add{$_} .= '@' . $domain{name};
					$condition .= "$_='$post_add{$_}'";
				}                
			} else {                       
				$condition .= "$_='$post_add{$_}'";
			}           
		}
	}

	$start_index   = $post_add{page} * $post_add{limit};
	$start_index ||= 0;

	$limit         = $post_add{limit};
	$limit       ||= 100;

	$condition   ||= '1=1';
	warn $condition;

	%hash = &database_select_as_hash(
		"select
		1,count(*)
		from
		v_xml_cdr
		where
		$condition",
		"total");
	$response{data}{total} = $hash{1}{total} ? $hash{1}{total} : 0;

	#$fields = 'uuid,uuid,caller_id_name,caller_id_number,destination_number,start_stamp,billsec,pdd_ms,rtp_audio_in_mos,hangup_cause,start_epoch,cc_queue,queue_extension,direction,bridge_uuid,sip_hangup_disposition,answer_stamp';
	##$fields = 'uuid,uuid,b_call_id,a_call_id,caller_id_name,caller_id_number,destination_number,start_stamp,billsec,pdd_ms,rtp_audio_in_mos,hangup_cause,start_epoch,cc_queue,queue_extension,direction,bridge_uuid,sip_hangup_disposition,answer_stamp';
	$fields = 'xml_cdr_uuid,xml_cdr_uuid,b_call_id,caller_id_name,caller_id_number,destination_number,start_stamp,billsec,pdd_ms,rtp_audio_in_mos,hangup_cause,start_epoch,cc_queue,queue_extension,direction,bridge_uuid,sip_hangup_disposition,answer_stamp,extension_details,recording_url';
	#$fields1 = 'uuid,uuid,call_id,a_leg_call_id,caller_id_name,caller_id_number,destination_number,start_stamp,billsec,pdd_ms,rtp_audio_in_mos,hangup_cause,start_epoch,cc_queue,queue_extension,direction,bridge_uuid,sip_hangup_disposition,answer_stamp';
	$fields1 = 'xml_cdr_uuid,xml_cdr_uuid,sip_call_id,caller_id_name,caller_id_number,destination_number,start_stamp,billsec,pdd_ms,rtp_audio_in_mos,hangup_cause,start_epoch,cc_queue,call_center_queue_uuid,direction,bridge_uuid,sip_hangup_disposition,answer_stamp,extension_details,remove_s3_recording';
	if ($response{stat} ne 'fail') {

		%hash = &database_select_as_hash(
			"select
			xml_cdr_uuid,$fields1
			from
			v_xml_cdr
			where
			$condition
			limit $limit offset $start_index",
			"$fields");


		for (sort {$hash{$b}{start_stamp} cmp $hash{$a}{start_stamp}} keys %hash) {
			local $start_epoch = $hash{$_}{start_epoch};
			local $uuid				 = $_;

			local $recording_filename = "/var/lib/freeswitch/recordings/$domain{name}/archive/". strftime('%Y', localtime($start_epoch)) . "/" . strftime('%b',  localtime($start_epoch)) . "/" . strftime('%d', localtime($start_epoch)) .  "/$uuid.wav";
			if (!-e $recording_filename) {
				$recording_filename  = "/var/lib/freeswitch/recordings/$domain{name}/archive/". strftime('%Y', localtime($start_epoch)) . "/" . strftime('%b',  localtime($start_epoch)) . "/" . strftime('%d', localtime($start_epoch)) .  "/$uuid.mp3";
			}

			warn $recording_filename;
			$recording_url = '';
			if (-e $recording_filename) {
				$recording_url = "https://$domain{name}/app/recordings/recordings2.php?filename=" . encode_base64($recording_filename, '');
				$hash{$_}{recording_url} = $recording_url;
			}
			  ## Date=03-11-2023  Added by Atul for S3 recording
                        else
                        {
                         $hash{$_}{recording_url}=$hash{$_}{recording_url};
                        }
                        ### END

			local $queue_name = $hash{$_}{cc_queue};
			if ($queue_name) {
				local ($n) = split '@', $queue_name;
				local $e = $queues{$n}{queue_extension};
				local $d = $queues{$n}{call_center_queue_uuid};
				## Date :05-3-2024 Added by Atul for get cc-queue-name in cdr
				local $sql = "SELECT 1,queue_name from v_call_center_queues where domain_uuid='$domain{uuid}' and queue_extension='$n'";
                   local %data = &database_select_as_hash($sql, "queue_name");
                   $cc_queue_name=$data{1}{queue_name};
                   $hash{$_}{cc_queue_name} = $cc_queue_name;
				### END 
				$hash{$_}{cc_queue} = $n;
				$hash{$_}{queue_extension} = $e;
				$hash{$_}{queue_uuid} = $d;
			} else {
				$hash{$_}{cc_queue} = '';
				$hash{$_}{queue_extension} = '';
				$hash{$_}{queue_uuid} = '';                
				$hash{$_}{cc_queue_name} = '';                
			}

			if ($hash{$_}{direction} eq 'inbound' or $hash{$_}{direction} eq 'local') {
				if ($hash{$_}{answer_stamp} && $hash{$_}{bridge_uuid}) {
					$call_result = 'answered';
				} elsif($hash{$_}{answer_stamp} && !$hash{$_}{bridge_uuid}) {
					$call_result = 'voicemail';
				} elsif(!$hash{$_}{answer_stamp} && !$hash{$_}{bridge_uuid} && $hash{$_}{sip_hangup_disposition} ne 'send_refuse') {
					$call_result = 'cancelled';
				} else {
					$call_result = 'failed';
				}

			} elsif ($hash{$_}{direction} eq 'outbound') {
				if ($hash{$_}{answer_stamp} && $hash{$_}{bridge_uuid}) {
					$call_result = 'answered';
				} elsif(!$hash{$_}{answer_stamp} && $hash{$_}{bridge_uuid}) {
					$call_result = 'cancelled';
				} else {
					$call_result = 'failed';
				}
			}

			$hash{$_}{call_result} = $call_result;

			push @{$response{data}{list}}, $hash{$_};
		}
	}

	$response{stat} = 'ok';
	&print_json_response(%response);
}

###########################################################
##########DATE : 05-11-2020 
########## Added by Atul for get remote cdr
###########################################################
sub getarchivecdr123(){
=pod
    use DBI; 
    my $remote_dbname = 'fusionpbx';  
    my $remote_host = '192.168.1.147';  
    my $remote_port = 5432;  
    my $remote_username = 'fusionpbx';  
    my $remote_password = 'KEPNexDVW5WxklWnxiw7rViXAk';  
    my $dbh = DBI -> connect("dbi:Pg:dbname=$remote_dbname;host=$remote_host;port=$remote_port",$remote_username,$remote_password) or die $DBI::errstr;

	#my $stmt = qq(SELECT xml_cdr_uuid,domain_uuid,domain_name,context from v_xml_cdr);

	my $stmt = qq(SELECT *  from v_xml_cdr);
	my $sth = $dbh->prepare( $stmt );
	$list =[];
	my $rv = $sth->execute() or die $DBI::errstr;
	   while(my @row = $sth->fetchrow_array()) {
				 push @$list,$row[0];		   
				 push @$list,$row[1];		   
				 push @$list,$row[2];		   
				 push @$list,$row[3];		   

				   }
				   print "Operation done successfully\n";
				   $dbh->disconnect();
=cut



%response       = ();   
%hash=  &database_select_as_hash_remote("select * from v_xml_cdr");
$list  = [];
for (sort {$hash{$a}{domain_uuid} cmp $hash{$b}{domain_uuid}} keys %hash) {
	push @$list, {phonenumber => $_,domain_name => $hash{$_}{domain_uuid}};

}

$response{stat} = 'ok';
$response{stat1} = $list;

&print_json_response(%response);  
}
###########	END #########################

############################################################
###########date :06-11-2020
########### Developed by :Atul Akabari
########### Purpose : for get data from the remote server 
###########################################################

sub getarchivecdr () {
	local %post_add = ();
	%response       = ();   
	%domain         = &get_domain();


	local %params = (
		uuid => {type => 'string', maxlen => 36, notnull => 0, default => ''},
		direction => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		caller_id_number => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		destination_number => {type => 'string', maxlen => 50, notnull => 0, default => ''},        
		start_stamp => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		end_stamp => {type => 'string', maxlen => 50, notnull => 0, default =>''},
		caller_id_name => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		page => {type => 'int', maxlen => 50, notnull => 0, default => 0},
		limit => {type => 'int', maxlen => 50, notnull => 0, default => 100},
		missed => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
		cc_queue => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		queue_extension => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		cc_result => {type => 'string', maxlen => 50, notnull => 0, default => ''}
	);


	if (!$domain{name}) {
		&print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}


	for $k (keys %params) {
		$tmpval   = '';
		if (&getvalue(\$tmpval, $k, $params{$k})) {
			$post_add{$k} = $tmpval;
		} else {
			$response{stat}         = "fail";
			$response{message}  = $k. &_(" not valid");
		}
	}

	%queues = &database_select_as_hash_remote(
		"select
		queue_name,queue_extension,call_center_queue_uuid
		from
		v_call_center_queues
		where
		domain_uuid='$domain{uuid}'",
		"queue_extension,call_center_queue_uuid");



	#$condition = "domain_uuid='$domain{uuid}'";
	$condition = "domain_uuid='8d7f7c81-61bf-4c5f-ac03-7db8e3bc880d'";
	for (keys %post_add) {
		next if  !$_ || $post_add{$_} eq '' || $_ eq 'page' || $_ eq 'limit';
		$condition .= ' AND ' if $condition;
		if ($_ eq 'start_stamp') {
			$condition .= "start_stamp >= '$post_add{start_stamp}'";
		} elsif ($_ eq 'end_stamp') {
			$condition .= "end_stamp <= '$post_add{end_stamp}'";
		} elsif ($_ eq 'missed' ) {
			if ($post_add{missed} eq 'true') {
				$condition .= "billsec=0"
			} else {
				$condition .= " 1=1 ";
			}
		} elsif ($_ eq 'call_result' ) {
			if ($post_add{call_result} eq 'answered') {
				$condition .= "(answer_stamp is not null and bridge_uuid is not null)";
			} elsif ($post_add{call_result} eq 'voicemail') {
				$condition .= "(answer_stamp is not null and bridge_uuid is null)";
			} elsif ($post_add{call_result} eq 'missed' || $post_add{call_result} eq 'cancelled') {
				$condition .= " (answer_stamp is not null and bridge_uuid is null) ";
			} elsif ($post_add{call_result} eq 'failed') {
				$condition .= "(answer_stamp is null and bridge_uuid is null and billsec = 0 and sip_hangup_disposition = 'send_refuse')";
			} 
		} else {
			if ($_ eq 'cc_queue' ) {
				if (lc($post_add{$_}) eq 'null' or lc($post_add{$_}) eq 'not null') {
					$condition .= "$_ IS $post_add{$_}"; next;
				} elsif (index($post_add{$_}, '@') == -1) {
					$post_add{$_} .= '@' . $domain{name};
					$condition .= "$_='$post_add{$_}'";
				}                
			} else {                       
				$condition .= "$_='$post_add{$_}'";
			}           
		}
	}

	$start_index   = $post_add{page} * $post_add{limit};
	$start_index ||= 0;

	$limit         = $post_add{limit};
	$limit       ||= 100;

	$condition   ||= '1=1';
	warn $condition;

	%hash = &database_select_as_hash_remote(
		"select
		1,count(*)
		from
		v_xml_cdr
		where
		$condition",
		"total");


	$response{data}{total} = $hash{1}{total} ? $hash{1}{total} : 0;

	#$fields = 'uuid,uuid,caller_id_name,caller_id_number,destination_number,start_stamp,billsec,pdd_ms,rtp_audio_in_mos,hangup_cause,start_epoch,cc_queue,queue_extension,direction,bridge_uuid,sip_hangup_disposition,answer_stamp';
	$fields = 'xml_cdr_uuid,xml_cdr_uuid,caller_id_name,caller_id_number,destination_number,start_stamp,billsec,pdd_ms,rtp_audio_in_mos,hangup_cause,start_epoch,cc_queue,direction,bridge_uuid,sip_hangup_disposition,answer_stamp';
	if ($response{stat} ne 'fail') {

		#	%hash = &database_select_as_hash_remote("select uuid,$fields from v_xml_cdr where $condition limit $limit offset $start_index","$fields");
		%hash = &database_select_as_hash_remote("select xml_cdr_uuid,$fields from v_xml_cdr where $condition limit $limit offset $start_index","$fields");


		for (sort {$hash{$b}{start_stamp} cmp $hash{$a}{start_stamp}} keys %hash) {
			local $start_epoch = $hash{$_}{start_epoch};
			local $uuid                              = $_;

			#local $recording_filename = "/var/lib/freeswitch/recordings/$domain{name}/archive/". strftime('%Y', localtime($start_epoch)) . "/" . strftime('%b',  localtime($start_epoch)) . "/" . strftime('%d', localtime($start_epoch)) .  "/$uuid.wav";
			local $recording_filename = "/var/lib/freeswitch/recordings/192.168.1.147/archive/". strftime('%Y', localtime($start_epoch)) . "/" . strftime('%b',  localtime($start_epoch)) . "/" . strftime('%d', localtime($start_epoch)) .  "/$uuid.wav";



			if (!-e $recording_filename) {
				#$recording_filename  = "/var/lib/freeswitch/recordings/$domain{name}/archive/". strftime('%Y', localtime($start_epoch)) . "/" . strftime('%b',  localtime($start_epoch)) . "/" . strftime('%d', localtime($start_epoch)) .  "/$uuid.mp3";
				$recording_filename  = "/var/lib/freeswitch/recordings/192.168.1.147/archive/". strftime('%Y', localtime($start_epoch)) . "/" . strftime('%b',  localtime($start_epoch)) . "/" . strftime('%d', localtime($start_epoch)) .  "/$uuid.mp3";
			}

			warn $recording_filename;
			$recording_url = '';
			if (-e $recording_filename) {
				$recording_url = "https://$domain{name}/app/recordings/recordings2.php?filename=" . encode_base64($recording_filename, '');
				$hash{$_}{recording_url} = $recording_url;
			}


			local $queue_name = $hash{$_}{cc_queue};
			if ($queue_name) {
				local ($n) = split '@', $queue_name;
				local $e = $queues{$n}{queue_extension};
				local $d = $queues{$n}{call_center_queue_uuid};

				$hash{$_}{cc_queue} = $n;
				$hash{$_}{queue_extension} = $e;
				$hash{$_}{queue_uuid} = $d;
			} else {
				$hash{$_}{cc_queue} = '';
				$hash{$_}{queue_extension} = '';
				$hash{$_}{queue_uuid} = '';                
			}

			if ($hash{$_}{direction} eq 'inbound' or $hash{$_}{direction} eq 'local') {
				if ($hash{$_}{answer_stamp} && $hash{$_}{bridge_uuid}) {
					$call_result = 'answered';
				} elsif($hash{$_}{answer_stamp} && !$hash{$_}{bridge_uuid}) {
					$call_result = 'voicemail';
				} elsif(!$hash{$_}{answer_stamp} && !$hash{$_}{bridge_uuid} && $hash{$_}{sip_hangup_disposition} ne 'send_refuse') {
					$call_result = 'cancelled';
				} else {
					$call_result = 'failed';
				}

			} elsif ($hash{$_}{direction} eq 'outbound') {
				if ($hash{$_}{answer_stamp} && $hash{$_}{bridge_uuid}) {
					$call_result = 'answered';
				} elsif(!$hash{$_}{answer_stamp} && $hash{$_}{bridge_uuid}) {
					$call_result = 'cancelled';
				} else {
					$call_result = 'failed';
				}
			}

			$hash{$_}{call_result} = $call_result;

			push @{$response{data}{list}}, $hash{$_};
		}
	}

	$response{stat} = 'ok';
	&print_json_response(%response);

}

#################END ######################################
#####Date :25-Feb-2021
#####Developed By :- Atul Akabari 
#####Purpose :-Get CDR API for CRM NEW API
sub get_crmcdr(){
	local %post_add = ();
	%response       = ();   
	%domain         = &get_domain();

	local %params = (
		phone_numbers => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		start_stamp => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		end_stamp => {type => 'string', maxlen => 50, notnull => 0, default =>''},
		caller_id_name => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		page => {type => 'int', maxlen => 50, notnull => 0, default => 0},
		limit => {type => 'int', maxlen => 50, notnull => 0, default => 100},

	);
	if (!$domain{name}) {
		&print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}
	for $k (keys %params) {
		$tmpval   = '';
		if (&getvalue(\$tmpval, $k, $params{$k})) {
			$post_add{$k} = $tmpval;
		} else {
			$response{stat}	    = "fail";
			$response{message}	= $k. &_(" not valid");
		}
	}

	if($post_add{phone_numbers} ne '')
	{
		$phone_number=$post_add{phone_numbers};
		$phone_number =~s/;/','/ig;
		$phone_number="'".$phone_number."'";
		$condition=$phone_number;
		$limit=10;
	}	

	#$start_stamp="AND CAST(start_stamp AS text) LIKE '%$post_add{start_stamp}%'";
	#$end_stamp="AND CAST(end_stamp AS text) LIKE '%$post_add{end_stamp}%'";
	$start_stamp="$post_add{start_stamp}";
	$end_stamp="$post_add{end_stamp}";
	$fields = 'uuid,domain_uuid,caller_id_name,caller_id_number,destination_number,start_stamp,billsec,pdd_ms,rtp_audio_in_mos,hangup_cause,start_epoch,cc_queue,queue_extension,direction,bridge_uuid,sip_hangup_disposition,answer_stamp';
	$sql="select $fields from v_xml_cdr where caller_id_name IN($condition) and domain_uuid='$domain{uuid}' AND start_stamp >= '$start_stamp' AND end_stamp <= '$end_stamp' limit $limit";
	%hash = &database_select_as_hash(
		"select 
		$fields
		from
		v_xml_cdr
		where caller_id_name IN($condition)
		AND start_stamp >= '$start_stamp'
		AND start_stamp <= '$end_stamp'
		AND domain_uuid='$domain{uuid}'

		limit $limit","$fields");

	for (sort {$hash{$b}{start_stamp} cmp $hash{$a}{start_stamp}} keys %hash) {


		$hash{$_}{call_result} = $call_result;

		push @{$response{data}{list}}, $hash{$_};

	}





	$response{stat} = "Ok";
	$response{sql} = $sql;
	&print_json_response(%response);

}



###################END ##################################
############ Date :26-Feb-2021
############ Added By :Atul Akabari
############ Purpose :- GetCDR REPORT FOR CRM BY MULTIPLE PHONE NUMBER

sub getcdrbynumbers () {
	local %post_add = ();
	%response       = ();   
	%domain         = &get_domain();


	local %params = (
		#uuid => {type => 'string', maxlen => 36, notnull => 0, default => ''},
		#direction => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		#caller_id_number => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		#destination_number => {type => 'string', maxlen => 50, notnull => 0, default => ''},        
		start_stamp => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		end_stamp => {type => 'string', maxlen => 50, notnull => 0, default =>''},
		caller_id_name => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		page => {type => 'int', maxlen => 50, notnull => 0, default => 0},
		limit => {type => 'int', maxlen => 50, notnull => 0, default => 100},
		#missed => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
		#cc_queue => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		#queue_extension => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		#cc_result => {type => 'string', maxlen => 50, notnull => 0, default => ''}
		phone_numbers => {type => 'string', maxlen => 50, notnull => 0, default => ''},
	);


	if (!$domain{name}) {
		&print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}



	for $k (keys %params) {
		$tmpval   = '';
		if (&getvalue(\$tmpval, $k, $params{$k})) {
			$post_add{$k} = $tmpval;
		} else {
			$response{stat}	    = "fail";
			$response{message}	= $k. &_(" not valid");
		}
	}

	%queues = &database_select_as_hash(
		"select
		queue_name,queue_extension,call_center_queue_uuid
		from
		v_call_center_queues
		where
		domain_uuid='$domain{uuid}'",
		"queue_extension,call_center_queue_uuid,queue_name");

	$condition = "domain_uuid='$domain{uuid}'";
	for (keys %post_add) {
		next if  !$_ || $post_add{$_} eq '' || $_ eq 'page' || $_ eq 'limit';
		$condition .= ' AND ' if $condition;
		if ($_ eq 'start_stamp') {
			$condition .= "start_stamp >= '$post_add{start_stamp}'";
		} elsif ($_ eq 'end_stamp') {
			$condition .= "end_stamp <= '$post_add{end_stamp}'";
		}


	 ##Date :-21-09-23 Added by Atul for check outbound caller id number
	
		elsif($_ eq 'phone_numbers'){
        local $sql = "SELECT 1,outbound_caller_id_number from v_extensions where domain_uuid='$domain{uuid}' and extension IN ('$post_add{phone_numbers}')";

                local %data = &database_select_as_hash($sql, "outbound_caller_id_number");
                $outbound_caller_id=$data{1}{outbound_caller_id_number};

        ##end
		


		# ADDED BY ATUL
	##	elsif($_ eq 'phone_numbers'){
			$phone_number=$post_add{phone_numbers};
			$number_len= length($phone_number);
			if($number_len eq 10 ) 
			{
				$number1="'1".$phone_number."'";
			}
			else
			{
				$number1="'".$phone_number."'";
			}
			$phone_number =~s/;/','/ig;
			$phone_number="'".$phone_number."'";
			$outbound_caller_id="'".$outbound_caller_id."'";
			$condition1="(caller_id_number IN ($phone_number,$outbound_caller_id,$number1)";
			$condition1.="OR caller_id_name IN ($phone_number,$outbound_caller_id,$number1)";
			$condition1.="OR destination_number IN ($phone_number,$outbound_caller_id,$number1)";
			$condition1.="OR caller_destination IN ($phone_number,$outbound_caller_id,$number1)";
			$condition1.="OR extension_details IN ($phone_number,$outbound_caller_id,$number1)";
			$condition1.="OR source_number IN ($phone_number,$outbound_caller_id,$number1))";
			$condition.=$condition1;
			
		}

		#END 

		elsif ($_ eq 'missed' ) {
			if ($post_add{missed} eq 'true') {

				$condition .= "billsec=0"
			} else {
				$condition .= " 1=1 ";
			}
		} elsif ($_ eq 'call_result' ) {
			if ($post_add{call_result} eq 'answered') {
				$condition .= "(answer_stamp is not null and bridge_uuid is not null)";
			} elsif ($post_add{call_result} eq 'voicemail') {
				$condition .= "(answer_stamp is not null and bridge_uuid is null)";
			} elsif ($post_add{call_result} eq 'missed' || $post_add{call_result} eq 'cancelled') {
				$condition .= " (answer_stamp is not null and bridge_uuid is null) ";
			} elsif ($post_add{call_result} eq 'failed') {
				$condition .= "(answer_stamp is null and bridge_uuid is null and billsec = 0 and sip_hangup_disposition = 'send_refuse')";
			} 
		} else {
			if ($_ eq 'cc_queue' ) {
				if (lc($post_add{$_}) eq 'null' or lc($post_add{$_}) eq 'not null') {
					$condition .= "$_ IS $post_add{$_}"; next;
				} elsif (index($post_add{$_}, '@') == -1) {
					$post_add{$_} .= '@' . $domain{name};
					$condition .= "$_='$post_add{$_}'";
				}                
			} else {                       
				$condition .= "$_='$post_add{$_}'";
			}           
		}
	}

	$start_index   = $post_add{page} * $post_add{limit};
	$start_index ||= 0;

	$limit         = $post_add{limit};
	$limit       ||= 100;

	$condition   ||= '1=1';
	warn $condition;

	%hash = &database_select_as_hash(
		"select
		1,count(*)
		from
		v_xml_cdr
		where
		$condition",
		"total");
	$response{data}{total} = $hash{1}{total} ? $hash{1}{total} : 0;

	 $fields1 = 'xml_cdr_uuid,xml_cdr_uuid,b_call_id,caller_id_name,caller_id_number,destination_number,start_stamp,billsec,pdd_ms,rtp_audio_in_mos,hangup_cause,start_epoch,cc_queue,queue_extension,direction,bridge_uuid,sip_hangup_disposition,answer_stamp,extension_details,recording_url';
	# $fields1 = 'uuid,uuid,b_call_id,a_call_id,caller_id_name,caller_id_number,destination_number,start_stamp,billsec,pdd_ms,rtp_audio_in_mos,hangup_cause,start_epoch,cc_queue,call_center_queue_uuid,direction,bridge_uuid,sip_hangup_disposition,answer_stamp,extension_details';

	$fields = 'xml_cdr_uuid,xml_cdr_uuid,sip_call_id,caller_id_name,caller_id_number,destination_number,start_stamp,billsec,pdd_ms,rtp_audio_in_mos,hangup_cause,start_epoch,cc_queue,call_center_queue_uuid,direction,bridge_uuid,sip_hangup_disposition,answer_stamp,extension_details,remove_s3_recording as recording_url';
	#$fields = 'uuid,uuid,call_id,a_leg_call_id,alternate_cid_name,caller_id_number,destination_number,start_stamp,billsec,pdd_ms,rtp_audio_in_mos,hangup_cause,start_epoch,cc_queue,queue_extension,direction,bridge_uuid,sip_hangup_disposition,answer_stamp,remove_s3_recording';
	if ($response{stat} ne 'fail') {

		%hash = &database_select_as_hash(
			"select
			xml_cdr_uuid,$fields
			from
			v_xml_cdr
			where
			$condition ORDER BY start_stamp Desc
			limit $limit offset $start_index",
			"$fields1");


		for (sort {$hash{$b}{start_stamp} cmp $hash{$a}{start_stamp}} keys %hash) {
			local $start_epoch = $hash{$_}{start_epoch};
			local $uuid				 = $_;

			local $recording_filename = "/var/lib/freeswitch/recordings/$domain{name}/archive/". strftime('%Y', localtime($start_epoch)) . "/" . strftime('%b',  localtime($start_epoch)) . "/" . strftime('%d', localtime($start_epoch)) .  "/$uuid.wav";
			if (!-e $recording_filename) {
				$recording_filename  = "/var/lib/freeswitch/recordings/$domain{name}/archive/". strftime('%Y', localtime($start_epoch)) . "/" . strftime('%b',  localtime($start_epoch)) . "/" . strftime('%d', localtime($start_epoch)) .  "/$uuid.mp3";
			}

			warn $recording_filename;
			$recording_url = '';
			if (-e $recording_filename) {
				$recording_url = "https://$domain{name}/app/recordings/recordings2.php?filename=" . encode_base64($recording_filename, '');
				$hash{$_}{recording_url} = $recording_url;
			}

			## Date=03-11-2023  Added by Atul for S3 recording
			else
			{
			 $hash{$_}{recording_url}=$hash{$_}{recording_url};
			}
			### END
			
			local $queue_name = $hash{$_}{cc_queue};
			if ($queue_name) {
				local ($n) = split '@', $queue_name;
				local $e = $queues{$n}{queue_extension};
				local $d = $queues{$n}{call_center_queue_uuid};

				$hash{$_}{cc_queue} = $n;
				local $sql = "SELECT 1,queue_name from v_call_center_queues where domain_uuid='$domain{uuid}' and queue_extension='$n'";
                		local %data = &database_select_as_hash($sql, "queue_name");
                		$cc_queue_name=$data{1}{queue_name};
				$hash{$_}{cc_queue_name} = $cc_queue_name;
				$hash{$_}{queue_extension} = $e;
				$hash{$_}{queue_uuid} = $d;
				
			} else {
				$hash{$_}{cc_queue} = '';
				$hash{$_}{queue_extension} = '';
				$hash{$_}{queue_uuid} = '';                
				$hash{$_}{cc_queue_name} = '';                
			}

			if ($hash{$_}{direction} eq 'inbound' or $hash{$_}{direction} eq 'local') {
				if ($hash{$_}{answer_stamp} && $hash{$_}{bridge_uuid}) {
					$call_result = 'answered';
				} elsif($hash{$_}{answer_stamp} && !$hash{$_}{bridge_uuid}) {
					$call_result = 'voicemail';
				} elsif(!$hash{$_}{answer_stamp} && !$hash{$_}{bridge_uuid} && $hash{$_}{sip_hangup_disposition} ne 'send_refuse') {
					$call_result = 'cancelled';
				} else {
					$call_result = 'failed';
				}

			} elsif ($hash{$_}{direction} eq 'outbound') {
				if ($hash{$_}{answer_stamp} && $hash{$_}{bridge_uuid}) {
					$call_result = 'answered';
				} elsif(!$hash{$_}{answer_stamp} && $hash{$_}{bridge_uuid}) {
					$call_result = 'cancelled';
				} else {
					$call_result = 'failed';
				}
			}

			if($hash{$_}{alternate_cid_name} ne '')
			{
				$hash{$_}{caller_id_name}=$hash{$_}{alternate_cid_name};
			}
			#if($hash{$_}{call_id})
			#{
			#	$hash{$_}{b_call_id}=$hash{$_}{call_id};
			#}

			$hash{$_}{call_result} = $call_result;

			push @{$response{data}{list}}, $hash{$_};
		}
	}

##	$response{stat1} = $condition;
##	$response{stat2} = $number_len;
##	$response{stat33}= %queues;
	$response{stat} = 'ok';
	&print_json_response(%response);
}



########################END ############################## 
sub getcdrmissed () {
	$form{missed} = 1;
	&getcdr();
}

sub getcdrstatistics () {
	local %post_add = ();
	%response       = ();   
	%domain         = &get_domain();

	if (!$domain{name}) {
		&print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}

	%hash = &database_select_as_hash("select 1,extract(epoch from now())", 'epoch');
	$current_epoch = int $hash{1}{epoch};
	$epoch_before1day = $current_epoch - 24*3600;
	$epoch_before30day= $current_epoch - 24*3600*30;
	$fields = 'xml_cdr_uuid,start_stamp,start_epoch,billsec';
	if ($response{stat} ne 'fail') {
		%hash = &database_select_as_hash(
			"select
			xml_cdr_uuid,$fields
			from
			v_xml_cdr
			where
			start_epoch >= '$epoch_before1day'",                            
			"$fields");

		for (1..24) {
			$response{data}{hours}{$_}{volume} = 0;
			$response{data}{hours}{$_}{minutes} = 0;
			$response{data}{hours}{$_}{callsperminute} = 0;
			$response{data}{hours}{$_}{missed} = 0;
			$response{data}{hours}{$_}{asr} = 0;
			$response{data}{hours}{$_}{aloc} = 0;            
		}

		for (sort {$hash{$b}{start_epoch} <=> $hash{$a}{start_epoch}} keys %hash) {
			$i = int (($current_epoch - $hash{$_}{start_epoch}) / 3600) + 1;

			warn "$i: $hash{$_}{start_stamp}";

			$response{data}{hours}{$i}{volume}++;
			$response{data}{hours}{$i}{seconds} += $hash{$_}{billsec};
			$response{data}{hours}{$i}{missed}++ if $hash{$_}{billsec} <= 0;

			$response{data}{hours}{$i}{minutes} = sprintf("%.02f", $response{data}{hours}{$i}{seconds} / 60);
			$response{data}{hours}{$i}{callsperminute} = sprintf("%.02f", $response{data}{hours}{$i}{volume} / 60);

			if ($response{data}{hours}{$i}{volume} > 0) {
				$response{data}{hours}{$i}{asr} = int (($response{data}{hours}{$i}{volume}-$response{data}{hours}{$i}{missed}) /
					$response{data}{hours}{$i}{volume}) * 100;
			}

			$response{data}{hours}{$i}{aloc} = sprintf ("%.02f", $response{data}{hours}{$i}{minutes} /
				$response{data}{hours}{$i}{volume});

		}

		%hash = &database_select_as_hash(
			"select
			xml_cdr_uuid,$fields
			from
			v_xml_cdr
			where
			start_epoch >= '$epoch_before30day'",                            
			"$fields");

		for (1,7,30) {
			$response{data}{days}{$_}{volume} = 0;
			$response{data}{days}{$_}{minutes} = 0;
			$response{data}{days}{$_}{callsperminute} = 0;
			$response{data}{days}{$_}{missed} = 0;
			$response{data}{days}{$_}{asr} = 0;
			$response{data}{days}{$_}{aloc} = 0;            
		}

		for (sort {$hash{$b}{start_epoch} <=> $hash{$a}{start_epoch}} keys %hash) {
			$i = int($current_epoch - $hash{$_}{start_epoch}) / 3600 /24 + 1;
			$i = 7  if $i > 1 && $i <=7;
			$i = 30 if $i > 7 && $i <=30;

			warn "$i: $hash{$_}{start_stamp}";

			$response{data}{days}{$i}{volume}++;
			$response{data}{days}{$i}{seconds} += $hash{$_}{billsec};
			$response{data}{days}{$i}{missed}++ if $hash{$_}{billsec} <= 0;

			$response{data}{days}{$i}{minutes} = sprintf("%.02f", $response{data}{days}{$i}{seconds} / 60);
			$response{data}{days}{$i}{callsperminute} = sprintf("%.02f", $response{data}{days}{$i}{volume} / 60);
			if ($response{data}{days}{$i}{volume} > 0) {
				$response{data}{days}{$i}{asr} = int (($response{data}{days}{$i}{volume}-$response{data}{days}{$i}{missed}) /
					$response{data}{days}{$i}{volume}) * 100;
				$response{data}{days}{$i}{aloc} = sprintf ("%.02f", $response{data}{days}{$i}{minutes} /
					$response{data}{days}{$i}{volume});

			}


		}

	}

	$response{stat} = 'ok';
	&print_json_response(%response);  
}

return 1;
