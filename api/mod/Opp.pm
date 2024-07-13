=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

use POSIX qw(strftime);
##########################################################
#########date:26-July-2021
#######developed by : Hemant Chaudhari
#######purpose :- record_start (Operator Panel)

sub record_start()
{
	local $record_uuid 	= &database_clean_string(substr $form{record_uuid}, 0, 50);
	
	%domain    = &get_domain();
	$domain_name    = $domain{name};

	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}
	
	use POSIX qw(strftime);
	my $Y = strftime "%Y", localtime;
	my $month = strftime "%b", localtime;
	my $day = strftime "%d", localtime;

	$result =  &runswitchcommand('internal', "uuid_record ${record_uuid} start /var/lib/freeswitch/recordings/$domain_name/archive/$Y/$month/$day/$record_uuid.mp3");
	
	$result_1 = substr($result, 1, 3);
	  
	if($result_1 eq 'ERR') {
		&print_api_error_end_exit(90, " $result " . &_(""));
	}
	
	if (!$result) {
		&print_api_error_end_exit(90, " $result " . &_(""));
	}
	
	$response{stat} = 'ok';
	$response{message} = $result;
	$response{timestamp} = time;
	
	&print_json_response(%response);
}

##########################################################

##########################################################
#########date:26-July-2021
#######developed by : Hemant Chaudhari
#######purpose :- record_stop (Operator Panel)

sub record_stop()
{
	local $record_uuid 	= &database_clean_string(substr $form{record_uuid}, 0, 50);
	
	%domain    = &get_domain();
	$domain_name    = $domain{name};

	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}
	
	use POSIX qw(strftime);
	my $Y = strftime "%Y", localtime;
	my $month = strftime "%b", localtime;
	my $day = strftime "%d", localtime;

	$result =  &runswitchcommand('internal', "uuid_record ${record_uuid} stop /var/lib/freeswitch/recordings/$domain_name/archive/$Y/$month/$day/$record_uuid.mp3");
	
	$result_1 = substr($result, 1, 3);
	  
	if($result_1 eq 'ERR') {
		&print_api_error_end_exit(90, " $result " . &_(""));
	}
	
	if (!$result) {
		&print_api_error_end_exit(90, " $result " . &_(""));
	}
	
	$response{stat} = 'ok';
	$response{message} = $result;
	$response{timestamp}	= time;
	
	&print_json_response(%response);
}

##########################################################

##########################################################
#########date:21-07-2021
#######developed by : Hemant Chaudhari
#######purpose :- Operator Panel Eavesdrop

sub opp_eavesdrop()
{
	local $eavesdrop_dest 	= &database_clean_string(substr $form{eavesdrop_dest}, 0, 50);
	local $call_uuid = &database_clean_string(substr $form{call_uuid}, 0, 50);
	local $origination_caller_id_number = &database_clean_string(substr $form{origination_caller_id_number}, 0, 50);

	%domain    = &get_domain();
	$domain_name    = $domain{name};

		$sql="SELECT 1, user_uuid from v_users where username='Supervisor' LIMIT 1";
		warn $sql;
		%data_1 = &database_select_as_hash($sql,"user_uuid");
		$user_uuid=$data_1{1}{user_uuid};

		if (!$user_uuid) {

			$response{stat}        = 'fail';
			&print_api_error_end_exit(90, "You Are Not Permitted To Barge Call 1 " . &_(""));
			
		}
		
		$sql="SELECT 1, extension_uuid from v_extensions where extension='$eavesdrop_dest' and user_context='$domain_name'";
		warn $sql;
		%data_2 = &database_select_as_hash($sql,"extension_uuid");
		$extension_uuid=$data_2{1}{extension_uuid};
		
		$sql="SELECT 1, user_uuid from v_extension_users where user_uuid='$user_uuid' and extension_uuid='$extension_uuid'";
		warn $sql;
		%data_3 = &database_select_as_hash($sql,"user_uuid");
		$user_uuid_final=$data_3{1}{user_uuid};

		if (!$user_uuid_final) {

			$response{stat}        = 'fail';
			&print_api_error_end_exit(90, "You Are Not Permitted To Barge Call 2" . &_(""));
			
		}
		
		$sql="SELECT 1, group_name from v_group_users where user_uuid='$user_uuid_final' and group_name='Supervisor_With_Barge'";
		warn $sql;
		%data_4 = &database_select_as_hash($sql,"group_name");
		
		$group_name=$data_4{1}{group_name};
		
	#	if (!$group_name) {

	#		$response{stat}        = 'fail';
	#		&print_api_error_end_exit(90, "You Are Not Permitted To Barge Call 3" . &_(""));
			
	#	}
		
		$sql="SELECT 1, group_permission_uuid from v_group_permissions where permission_name = 'Enabled_call_barge' and group_name='Supervisor_With_Barge'";
		warn $sql;
		%data_4 = &database_select_as_hash($sql,"group_permission_uuid");
		$group_permission_uuid=$data_4{1}{group_permission_uuid};
				
		if (!$group_permission_uuid) {

			$response{stat}        = 'fail';
			&print_api_error_end_exit(90, "You Are Not Permitted To Barge Call 4 " . &_(""));
			
		}

		if (!$domain{name}) {
			&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
		}
		
	$cmd1 = &runswitchcommand('internal', "uuid_exists $call_uuid");
	
	if ($cmd1 eq 'true') {
	$result =  &runswitchcommand('internal',"luarun /usr/share/freeswitch/scripts/Opp_command.lua '$eavesdrop_dest' '$call_uuid' '$origination_caller_id_number' '$domain_name'");
	}else{
		&print_api_error_end_exit(90, "uuid not exists" . &_(""));
	}
	
	$response{stat}        = 'ok';
	$response{message}		   = $result;
	$response{timestamp}	= time;
	
	&print_json_response(%response);
}

sub get_call_groups() {

  local $poststring_add = '
call_group:';
     
     local %post_add = ();
     for (split /\n/, $poststring_add) {
          ($key, $val) = split ':', $_, 2;
          next if !$key;
          $post_add{$key} = $val;
     }
     $fields = join ",", keys %post_add;

     $response = ();
    
     %domain   = &get_domain();
     #$call_group  = &clean_str(substr($form{call_group},0,50),"MINIMAL","-_");

     if (!$domain{name}) {
          $response{stat}		= "ok";
          $response{message}	= "$domain not exists!";
     }
     
     %hash = &database_select_as_hash_with_key (
                                             "select 
                                                  DISTINCT call_group,v_extensions.*
                                             from
                                                  v_extensions where domain_uuid='$domain{uuid}' and call_group > '0' ",
                                             'call_group',
                                             "$fields");
				
     $response{stat}	= "ok";
     $response{timestamp} = time;
     $response{data}{list} = [];
	 
     for (sort {$hash{$a}{call_group} cmp $hash{$b}{call_group}} keys %hash) {	
          push  @{$response{data}{list}}, $hash{$_};
     }
		&print_json_response(%response);
}

sub get_call_groups_extension() {
 local $poststring_add = '
extension_uuid:
extension:10000
number_alias:
effective_caller_id_name:
effective_caller_id_number:
description:
call_group:
user_uuid:
user_status:
domain_uuid:879b9f9b-e69d-4181-9d81-f6775341cc7d';
     
     local %post_add = ();
     for (split /\n/, $poststring_add) {
          ($key, $val) = split ':', $_, 2;
          next if !$key;
          $post_add{$key} = $val;
     }
     $fields = join ",", keys %post_add;

     $response = ();
    
     %domain   = &get_domain();
     $call_group  = &clean_str(substr($form{call_group},0,50),"MINIMAL","-_");

     if (!$domain{name}) {
          $response{stat}		= "ok";
          $response{message}	= "$domain not exists!";
     }
     
     %hash = &database_select_as_hash_with_key (
                                             "select
                                                  extension_uuid,v_extensions.*
                                             from
                                                  v_extensions where domain_uuid='$domain{uuid}' and call_group = '$call_group'",
                                             'extension_uuid',
                                             "$fields");
     
     $response{stat}	= "ok";
     $response{timestamp} = time;
     
     $response{data}{list} = [];
     for (sort {$hash{$a}{extension} cmp $hash{$b}{extension}} keys %hash) {
          push @{$response{data}{list}}, $hash{$_};
     }
     
     &print_json_response(%response);
 
}
#created by Hemant chaudhary 02-08-21
sub change_agent_status() {
	
	%domain = &get_domain();
	$domain_name = $domain{name};
	local $status = &database_clean_string(substr $form{status}, 0, 50);
	local $user = &database_clean_string(substr $form{user_name}, 0, 50);

	local $sql = "SELECT 1,call_center_agent_uuid from v_call_center_agents where domain_uuid='$domain{uuid}' and agent_id='$user' limit 1";
        local %data = &database_select_as_hash($sql, "call_center_agent_uuid");

        $user=$data{1}{call_center_agent_uuid};
	
		$status =~ s/\%20/ /g;

		if ($status eq 'Do Not Disturb') {
			$status = '';
			$cmd = &runswitchcommand('internal', "callcenter_config agent set state $user\@$domain_name idle");
			#$cmd = &runswitchcommand('internal', "callcenter_config agent set state $user idle");
			$response{stat}          = 'ok';
			$response{message} 		 = $cmd;
			$response{timestamp} = time;
		}else{
	
		#$cmd = &runswitchcommand('internal', "callcenter_config agent set status $user\@$domain_name '$status'");
		$cmd = &runswitchcommand('internal', "callcenter_config agent set status $user '$status'");
		
		#$cmd_1 = &runswitchcommand('internal', "callcenter_config agent set state $user\@$domain_name Waiting");
		$cmd_1 = &runswitchcommand('internal', "callcenter_config agent set state $user Waiting");
		
		$result_1 = substr($cmd, 1, 3);
		
		}
		
		if($result_1 eq 'ERR') {
			&print_api_error_end_exit(90, " $cmd " . &_(""));
		}
	
		$response{stat}          = 'ok';
		$response{message} 		 = $cmd;
		$response{timestamp} = time;
		
	&print_json_response(%response);
	
}

sub getlivechannels () {
	%domain         = &get_domain();
	$domain_name    = $domain{name};
	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}

	$show_all	= $form{show_all};
	%channels 	= &parse_channels();

	for (sort {$channel{$b}{created_epoch} <=> $channel{$a}{created_epoch}} keys %channels) {
		if (!$show_all) {
			next unless $channels{$_}{context} eq $domain_name;
		}

		push @{$response{data}{channel_list}}, $channels{$_};
	}

	$response{stat} = 'ok';
	$response{timestamp} = time;
	
	&print_json_response(%response);	
}


sub makecall {	
	local $ext 	= &database_clean_string(substr $form{src}, 0, 50);
	if (!$ext) {		
		&print_api_error_end_exit(130, "src is null");
	}
	%domain      = &get_domain();
	$domain_name = $domain{name};
	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}	

	$auto_answer = $form{autoanswer}  ? "sip_h_Call-Info=<sip:$domain_name>;answer-after=0,sip_auto_answer=true" : "";
	$alert_info  = $form{autoanswer}  ? "sip_h_Alert-Info='Ring Answer'" : '';
	$dest	= $form{dest};
	if (!$form{dest}) {		
		&print_api_error_end_exit(130, "dest is null");
	}

	$accountcode = $form{accountcode};
	if ($accountcode) {
		$accountcode_str = "sip_h_X-accountcode=$accountcode";
	}

	$uuid   = &genuuid();
	if (!$uuid) {
		&print_api_error_end_exit(130, "uuid tool not defined");       
	}
	$dest =~ s/^\+1//g;
	if ($dest =~ /^\+(\d+)$/) {
		$dest = "011$1";
	}

	$realdest = $dest;

	$realdest = "$dest" unless $dest =~ /^(?:\+|011)/;

	$cid = &database_clean_string(substr $form{callerid}, 0, 50);
	$code = &_get_area_code($dest);
	$dcid = &_get_dynamic_callerid($ext, $domain{uuid}, $code);

	$cid = $dcid if $dcid;

	warn "dynamic_callerid: $ext $cid - $dcid!\n";
	@uri = &outbound_route_to_bridge($ext, $domain{uuid});
	if ($uri[0]) {
		$src_uri = $uri[0];
	} else {
		$src_uri = "user/$ext\@$domain{name}";
	}

	warn $src_uri;
	$year = strftime('%Y', localtime);
	$mon  = strftime('%b', localtime);
	$day  = strftime('%d', localtime);

	%hash = &database_select_as_hash("select 1,user_record from v_extensions where user_context='$domain_name' and extension='$ext'", 'record');
	if ($hash{1}{record} eq 'all' or $hash{1}{record} eq 'outbound') {
		$record = "api_on_answer='uuid_record $uuid start /usr/local/freeswitch/recordings/$domain_name/archive/$year/$mon/$day/$uuid.$record_format'";
	}
	$output = &runswitchcommand('internal', "bgapi originate {ringback=local_stream://default,ignore_early_media=true,fromextension=$ext,origination_caller_id_name=$cid,origination_caller_id_number=$ext,effective_caller_id_number=$cid,effective_caller_id_name=$cid,domain_name=$domain_name,outbound_caller_id_number=$cid,$alert_info,origination_uuid=$uuid,$accountcode_str,$auto_answer,record_session=true,$record}$src_uri  $realdest XML $domain_name");

	$response{stat}          = 'ok';
	$response{data}{uuid}    = $uuid;
	$response{timestamp} = time;	
	$response{message} = $output;   

	&print_json_response(%response);
}


sub hangup {
	local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);

	$output = &runswitchcommand('internal', "uuid_kill $uuid"
	);

	$result_1 = substr($output, 1, 3);
	  
	if($result_1 eq 'ERR') {
		&print_api_error_end_exit(90, "-ERR No such channel!\n" . &_(""));
	}
	
	$response{stat}          = 'ok';
	$response{message} = $output;
	$response{timestamp} = time;
	&print_json_response(%response);   	
}

#End
return 1;
