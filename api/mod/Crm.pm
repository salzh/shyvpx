=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

use POSIX qw(strftime);
$record_format = 'wav';
sub addincomingbycallerid () {
	local %params = (
		dialplan_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
		condition_field_1 => {type => 'string', maxlen => 20, notnull => 0, default => 'caller_id_number'},
		condition_expression_1 => {type => 'string', maxlen => 255, notnull => 0, default => ''},
		condition_field_2 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
		condition_expression_2 => {type => 'string', maxlen => 255, notnull => 0, default => ''},
		action_1 => {type => 'string', maxlen => 255, notnull => 1, default => ''},
		action_2 => {type => 'string', maxlen => 255, notnull => 0, default => ''},
		limit => {type => 'int', maxlen => 4, notnull => 0, default =>''},
		public_order => {type => 'int', maxlen => 4, notnull => 0, default => '100'},
		dialplan_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
		dialplan_description => {type => 'string', maxlen => 255, notnull => 0, default => ''},	
	);

	%response       = ();   
	%domain         = &get_domain();

	if (!$domain{name}) {
		$response{stat}		= "fail";
		$response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
	}

	
		$post_add{apirequest}="true";
	if ($response{stat} ne 'fail') {
		for $k (keys %params) {
			$tmpval   = '';
			if (&getvalue(\$tmpval, $k, $params{$k})) {
				$post_add{$k} = $tmpval;
			} else {
				$response{stat}		= "fail";
				$response{message}	= $k. &_(" not valid");
			}
		}
	}	

	if (!$response{stat} ne 'fail') {
		$post_add{dialplan_description} = "caller_id_number-$post_add{condition_expression_1}";
		$result = &post_data (
			'domain_uuid' => $domain{uuid},
			'urlpath'     => '/app/dialplan_inbound/dialplan_inbound_add.php?action=advanced',
			'reload'      => 0,
			'data'        => [%post_add]);
		#warn $result->header("Location");
		$location = $result->header("Location");
		
		($uuid) = $location =~ /app_uuid=(.+)$/;
		if (!$uuid) {
			$response{stat}		= "fail";
			$response{message}	= $k. &_(" not valid");
		} else {

			%hash = &database_select_as_hash(
				"select
					1,dialplan_uuid
				from 
					v_dialplans
				where
					dialplan_name='$post_add{dialplan_name}' and 
					app_uuid='c03b422e-13a8-bd1b-e42b-b6b9b4d27ce4'",
				"dialplan_uuid");

			$response{stat}		            = "ok";
			$response{data}{dialplan_uuid} = $hash{1}{dialplan_uuid};
		}       
	}

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
     $response{message}	= "ok";
     
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
     $response{message}	= "ok";
     
     $response{data}{list} = [];
     for (sort {$hash{$a}{extension} cmp $hash{$b}{extension}} keys %hash) {
          push @{$response{data}{list}}, $hash{$_};
     }
     
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
	&print_json_response(%response);   	
}

sub blindtransfer {
	local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);
	local ($dest) = &database_clean_string($form{dest});
	local  $direction = $form{direction} eq 'inbound' ? 'inbound': 'outbound';

	%calls = parse_calls();
	if ($direction eq 'inbound') {		
		for  (keys %calls) {
			$uuid_xtt =  $_ if $calls{$_}{b_uuid} eq $uuid;
		}
	} else {
		$uuid_xtt = $calls{$uuid}{b_uuid};	
	}

	if (!$uuid_xtt) {
		$response{stat}    = 'fail';
		$response{message} = '$uuid is not in any bridged call';
	} else {
		%domain         = &get_domain();
		$domain_name    = $domain{name};
		$output = &runswitchcommand('internal', "uuid_transfer $uuid_xtt $dest XML $domain_name");
		$response{stat}    = 'ok';
		$response{message} = $output;
	}

	&print_json_response(%response);
}

sub startattendedtransfer () {
	local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);
	local ($dest) = &database_clean_string($form{dest});
	local  $direction = $form{direction} eq 'inbound' ? 'inbound': 'outbound';

	%domain         = &get_domain();
	$domain_name    = $domain{name};
	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}

	local  $direction = $form{direction} eq 'inbound' ? 'inbound': 'outbound';
	%calls = &parse_calls();

	if ($direction eq 'inbound') {
		for  (keys %calls) {
			$uuid_xtt =  $_ if $calls{$_}{b_uuid} eq $uuid;
		}		
	} else  {
		$uuid_xtt = $calls{$uuid}{b_uuid};
		#($uuid_xtt, $uuid) = ($uuid, $uuid_xtt);
	}

	if (!$uuid_xtt) {
		warn "$uuid not in any calls!";
		&print_api_error_end_exit(160, "$uuid not in any $direction calls");
	}

	#check if api-park dialplan is created
	%hash = &database_select_as_hash("select
		1,dialplan_uuid,dialplan_number
		from
		v_dialplans
		where
		dialplan_context='default' and
		dialplan_name='api-park'",
		'dialplan_uuid,dialplan_number');
	if (!$hash{1}{dialplan_uuid}) {
		&print_api_error_end_exit(160, "dialplan of api-park not defined");        
	}

	$park_number = $hash{1}{dialplan_number};

	if (!$dest) {		
		&print_api_error_end_exit(130, "dest is null");
	}

	$accountcode = $form{accountcode};
	if ($accountcode) {
		#$accountcode_str = "sip_h_X-accountcode=$accountcode";
		&runswitchcommand('internal', "uuid_setvar $uuid sip_h_X-accountcode $accountcode");
	}


	$dest =~ s/^\+1//g;
	if ($dest =~ /^\+(\d+)$/) {
		$dest = "011$1";
	}

	$realdest = $dest;

	$realdest = "$dest" unless $dest =~ /^(?:\+|011)/;

	$cid = &database_clean_string(substr $form{callerid}, 0, 50);

	@uri = &outbound_route_to_bridge($realdest, $domain{uuid});
	if ($uri[0]) {
		$src_uri = $uri[0];
	} else {
		$src_uri = "user/$realdest\@$domain{name}";
	}

	warn $src_uri;
	$output = &runswitchcommand('internal', "uuid_setvar $uuid src_uri $src_uri");


	$output = &runswitchcommand('internal', "uuid_setvar $uuid uuid_xtt $uuid_xtt");
	$output = &runswitchcommand('internal', "uuid_dual_transfer $uuid  xtt/XML/default $park_number/XML/default");
	#$output = &runswitchcommand('internal', "uuid_dual_transfer $uuid  xtt/XML/default $park_number/XML/default");

	$response{stat}          = 'ok';
	$response{message} = $output;
	$response{park_number} = $park_number;
	&print_json_response(%response); 
}
#created by Hemant chaudhary 02-08-20
sub change_agent_status22() {
	
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
			#$cmd2 = &runswitchcommand('internal', "callcenter_config agent set state $user\@$domain_name idle");
			#$cmd2 = &runswitchcommand('internal', "callcenter_config agent set state $user idle");
			$cmd = &runswitchcommand('internal', "callcenter_config agent set state $user idle");
			$response{stat}          = 'ok';
			$response{timestamp} = time;
		}else{
	
		##$cmd2 = &runswitchcommand('internal', "callcenter_config agent set status $user\@$domain_name '$status'");
		##$cmd2 = &runswitchcommand('internal', "callcenter_config agent set status $user '$status'");
		$cmd = &runswitchcommand('internal', "callcenter_config agent set status $user '$status'");
		
		##$cmd_1 = &runswitchcommand('internal', "callcenter_config agent set state $user\@$domain_name Waiting");
		##$cmd_1 = &runswitchcommand('internal', "callcenter_config agent set state $user Waiting");
		$cmd_1 = &runswitchcommand('internal', "callcenter_config agent set state $user Waiting");
		
		$result_1 = substr($cmd, 1, 3);
		
		}
			
#		if($result_1 eq 'ERR') {
#			&print_api_error_end_exit(90, " $cmd " . &_(""));
#		}
	
		$response{stat}          = 'ok';
		$response{message} 		 = $cmd;
		$response{agent_uuid} 		 = $user;
		$response{timestamp} = time;
		
	&print_json_response(%response);
	
}
#End
sub cancelattendedtransfer() {
	local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);
	local  $direction = 'inbound'; #$form{direction} eq 'inbound' ? 'inbound': 'outbound';

	local $vspl_cancel = 'attended transfer cancel'; 

	$vspl_cancel = &runswitchcommand('internal', "uuid_setvar $uuid vspl_cancel $vspl_cancel");
	if ($direction eq 'outbound') {
		$uuid = &get_bchannel_uuid($uuid);
	}

	$uuid_xtt = &runswitchcommand('internal', "uuid_getvar $uuid uuid_xtt");
	$output   = &runswitchcommand('internal', "uuid_bridge $uuid $uuid_xtt");

	$response{stat}          = 'ok';
	$response{message} = $output;    

	&print_json_response(%response); 
}

sub confirmattendedtransfer() {
	local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);
	local  $direction = 'inbound';  #$form{direction} eq 'inbound' ? 'inbound': 'outbound';
	local $vspl_confirm = 'hello'; 
	if ($direction eq 'outbound') {
		$uuid = &get_bchannel_uuid($uuid);
	}

	$uuid_xtt = &runswitchcommand('internal', "uuid_getvar $uuid uuid_xtt");
	$vspl_confirm = &runswitchcommand('internal', "uuid_setvar $uuid vspl_confirm $vspl_confirm");
	%calls = &parse_calls();
	if (!$calls{$uuid}{b_uuid}) {
		warn "$uuid not in any calls!";
		&print_api_error_end_exit(160, "$uuid not in any calls");
	}

	$output   = &runswitchcommand('internal', "uuid_bridge $calls{$uuid}{b_uuid} $uuid_xtt");
	warn "uuid_bridge $calls{$uuid}{b_uuid} $uuid_xtt!!";
	
	$response{stat} = 'ok';    
	$response{message} = $output;    
	&print_json_response(%response);
}

#################################################
#Date :05-Jan-2021
#Developed by : Atul Akabari 
###purpose send pre-recorded voicemail 

sub play_pre_recorded_voicemail()
{
	local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);
	local $ext = &database_clean_string(substr $form{src}, 0, 50);
	%calls = &parse_calls();
	$agent2_data=$calls{$uuid}{b_uuid};
	%channels = &parse_channels();
	%domain = &get_domain();
	$domain_name = $domain{name};
	local $is_voicemail = 'true'; 
	$is_voicemail = &runswitchcommand('internal', "uuid_setvar $uuid is_voicemail $is_voicemail");

	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}
	$sql="SELECT 1 ,recordings_filename from v_pre_recorded_voicemails pre_vm,v_extensions v_ext where pre_vm.pre_recorded_voicemail_uuid=v_ext.pre_recorded_voicemail_uuid and v_ext.accountcode='$domain_name' and v_ext.pre_recorded_voicemail_enabled='true'and v_ext.extension='$ext'";
	warn $sql;
	%data = &database_select_as_hash($sql,"recordings_filename");
	$fname=$data{1}{recordings_filename};
	if(!$fname)
	{
		$response{status} = "You have not configured the pre recorded vm file to that extension ";
	}
	else
	{
		$filename="/var/lib/freeswitch/recordings/$domain_name/pre_recorded_vm/$fname";
		$sql="SELECT 1,recoding_duration from v_pre_recorded_voicemails where recordings_filename='$fname'";
		%data= &database_select_as_hash($sql,"recoding_duration");
		$recording_duration=$data{1}{recoding_duration};
		if(!$agent2_data)
		{

			$response{channel} = "channel not found ";
		}
		else{
			#$output = &runswitchcommand('internal', "uuid_broadcast $agent2_data $filename both");
			#$output = &runswitchcommand('internal', "sched_hangup +$recording_duration $agent2_data alotted_timeout");

			$output = &runswitchcommand('internal', "uuid_setvar $agent2_data filename $filename");
			$output = &runswitchcommand('internal', "uuid_dual_transfer $agent2_data vm/XML/default vma/XML/default");

			$response{status} = "Pre recorded voicemail sent successfully ";
		}
	}
	$response{stat} = 'ok';
	$response{record_file_name} = $fname;
	$response{agent_2data} = $agent2_data;
	&print_json_response(%response);
}


####################################################
#######date :24-Dec-2020
####### Developed by : Atul Akabari
###### purpose :Play as voicemail cusom recorded file.
sub play_pre_recorded_voicemail_orig()
{
	local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);
	local $ext 	= &database_clean_string(substr $form{src}, 0, 50);

	%domain    = &get_domain();
	$domain_name    = $domain{name};
	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}

	local $is_voicemail = 'true'; 
	$is_voicemail = &runswitchcommand('internal', "uuid_setvar $uuid is_voicemail $is_voicemail");

	$uuid_xtt = &runswitchcommand('internal', "uuid_getvar $uuid uuid_xtt");
	%calls = &parse_calls();
	$agent2_data=$calls{$uuid}{b_uuid};
	%channels = &parse_channels();
	$sql="SELECT 1 ,recordings_filename from v_pre_recorded_voicemail pre_vm,v_extensions v_ext where pre_vm.recording_uuid=v_ext.pre_recorded_voicemail_uuid and v_ext.accountcode='$domain_name' and v_ext.pre_recorded_voicemail_enabled='true'and v_ext.extension='$ext'";
	warn $sql;
	%data = &database_select_as_hash($sql,"recordings_filename");
	$fname=$data{1}{recordings_filename};
	$filename="/var/lib/freeswitch/recordings/$domain_name/pre_recorded_vm/$fname";
	$sql="SELECT 1,recoding_duration from v_pre_recorded_voicemail where recordings_filename='$fname'";
	%data= &database_select_as_hash($sql,"recoding_duration");
	$recording_duration=$data{1}{recoding_duration};	
	$agent_file="/var/lib/freeswitch/recordings/custom_recordings/agent_alert.wav";

	#$output = &runswitchcommand('internal', "uuid_broadcast $agent2_data $filename both");
	#$output = &runswitchcommand('internal', "sched_hangup +$recording_duration $agent2_data alotted_timeout");



	###Working #####

	$output = &runswitchcommand('internal', "uuid_setvar $agent2_data filename $filename");
	$output = &runswitchcommand('internal', "uuid_dual_transfer $agent2_data vm/XML/default vma/XML/default");

	$response{stat}        = 'ok';
	$response{status}      = "Pre recorded voicemail sent successfully ";

	&print_json_response(%response);
}


###################   END  ########################
###################################################
######date : 29-dec-2020
###### developed by : Atul akabari
#####purpose : record the voicemail  -recording 
sub record_voicemail_recording()
{
	local $ext 	= &database_clean_string(substr $form{src}, 0, 50);
	%domain    = &get_domain();
	$domain_name    = $domain{name};


	$sql="SELECT 1, extension_uuid from v_extensions where extension='$ext' and accountcode='$domain_name'";
	warn $sql;
	%data = &database_select_as_hash($sql,"extension_uuid");
	$extension_uuid=$data{1}{extension_uuid};


	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}
	$result =  &runswitchcommand('internal', "originate {origination_caller_id_name=callback-$ext,origination_caller_id_number=$ext,domain_uuid=$domain{uuid},extension_uuid='$extension_uuid',domain_name=$domain_name,ignore_early_media=true,flags=endconf|moderator}loopback/$ext/$domain_name/XML *733 XML $domain_name");

	$response{stat}        = 'ok';
	$response{status}        = $result;
	&print_json_response(%response);
}

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

	$result =  &runswitchcommand('internal', "bgapi uuid_record ${record_uuid} start /var/lib/freeswitch/recordings/$domain_name/archive/$Y/$month/$day/$record_uuid.mp3");

	if (!$result) {
		$response{stat}        = 'fail';
	}
		
	$response{stat}        = 'ok';
	$response{status}        = $result;
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

	$result =  &runswitchcommand('internal', "bgapi uuid_record ${record_uuid} stop /var/lib/freeswitch/recordings/$domain_name/archive/$Y/$month/$day/$record_uuid.mp3");

	if (!$result) {
		$response{stat}        = 'fail';
	}
	
	$response{stat}        = 'ok';
	$response{status}        = $result;
	&print_json_response(%response);
}

##########################################################

##########################################################
#########date:18-May-2021
#######developed by : Hemant Chaudhari
#######purpose :- Call Barge (Eavesdrop)

sub call_barge_api()
{
	local $from_ext 	= &database_clean_string(substr $form{from_ext}, 0, 50);
	local $barge_ext = &database_clean_string(substr $form{barge_ext}, 0, 50);
	%domain    = &get_domain();
	$domain_name    = $domain{name};

		if ($barge_ext) {
			$user_data = "user_data $barge_ext\'@\'$domain_name attr id";
			$result =  &runswitchcommand('internal', $user_data);			
			$result_1 = substr($result, 1, 3);
			
			$user_data_1 = "show channels like $result\'@\'";
			$result_ch =  &runswitchcommand('internal', $user_data_1);
			
			$channel_result = $variable = join('',split(/\n/,$result_ch));
			
			if($channel_result eq '0 total.') {
				&print_api_error_end_exit(90, "barge_ext channel not exists!" . &_(""));
			}
			
			if($result_1 eq 'ERR') {
				&print_api_error_end_exit(90, "barge_ext not exists!" . &_(""));
			}
			
			if (!$result) {
				&print_api_error_end_exit(90, "barge_ext not exists!" . &_(""));
			}
			
		}
		
	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}
	
	$result =  &runswitchcommand('internal', "originate {origination_caller_id_number=$from_ext,domain_uuid=$domain{uuid},extension_uuid='$extension_uuid',domain_name=$domain_name,ignore_early_media=true}loopback/$from_ext/$domain_name/XML *33$barge_ext XML $domain_name");

	$response{stat}        = 'ok';
	$response{status}        = $result;
	$response{timestamp} = time;
	
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
			&print_api_error_end_exit(90, "You Are Not Permitted To Barge Call " . &_(""));
			
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
			&print_api_error_end_exit(90, "You Are Not Permitted To Barge Call " . &_(""));
			
		}
		
		$sql="SELECT 1, group_name from v_group_users where user_uuid='$user_uuid_final' and group_name='Supervisor_With_Barge'";
		warn $sql;
		%data_4 = &database_select_as_hash($sql,"group_name");
		$group_name=$data_4{1}{group_name};
		
		if (!$group_name) {
			$response{stat}        = 'fail';
			&print_api_error_end_exit(90, "You Are Not Permitted To Barge Call " . &_(""));
			
		}
		
		$sql="SELECT 1, group_permission_uuid from v_group_permissions where permission_name = 'Enable_call_barge' and group_name='Supervisor_With_Barge'";
		warn $sql;
		%data_4 = &database_select_as_hash($sql,"group_permission_uuid");
		$group_permission_uuid=$data_4{1}{group_permission_uuid};
				
		if (!$group_permission_uuid) {
			$response{stat}        = 'fail';
			&print_api_error_end_exit(90, "You Are Not Permitted To Barge Call " . &_(""));
		}

		if (!$domain{name}) {
			&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
		}
	
		$cmd1 = &runswitchcommand('internal', "uuid_exists $call_uuid");
	
		if ($cmd1 eq 'true') {
			$result =  &runswitchcommand('internal',"luarun /usr/share/freeswitch/scripts/Opp_command.lua '$eavesdrop_dest' '$call_uuid' '$origination_caller_id_number' '$domain_name'");
		}else{
			&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid}" . &_("uuid not exists"));
		}
	
	$response{stat}        = 'ok';
	$response{status}        = $result;
	$response{timestamp} = time;
	
	&print_json_response(%response);
}

##########################################################

##########################################################
#########date:25-May-2021
#######developed by : Hemant Chaudhari
#######purpose :- Call Barge Without password (Eavesdrop)

sub call_barge_no_pwd()
{
	local $from_ext 	= &database_clean_string(substr $form{from_ext}, 0, 50);
	local $barge_ext = &database_clean_string(substr $form{barge_ext}, 0, 50);
	%domain    = &get_domain();
	$domain_name    = $domain{name};
		
		if ($barge_ext) {
			$user_data = "user_data $barge_ext\'@\'$domain_name attr id";
			$result =  &runswitchcommand('internal', $user_data);			
			$result_1 = substr($result, 1, 3);
			
			$user_data_1 = "show channels like $result\'@\'";
			$result_ch =  &runswitchcommand('internal', $user_data_1);
			
			$channel_result = $variable = join('',split(/\n/,$result_ch));
			
			if($channel_result eq '0 total.') {
				&print_api_error_end_exit(90, "barge_ext channel not exists!" . &_(""));
			}
			
			if($result_1 eq 'ERR') {
				&print_api_error_end_exit(90, "barge_ext not exists!" . &_(""));
			}
			
			if (!$result) {
				&print_api_error_end_exit(90, "barge_ext not exists!" . &_(""));
			}
			
		}
		$sql="SELECT 1, user_uuid from v_users where username='Supervisor' LIMIT 1";
		warn $sql;
		%data_1 = &database_select_as_hash($sql,"user_uuid");
		$user_uuid=$data_1{1}{user_uuid};

		if (!$user_uuid) {

			$response{stat}        = 'fail';
			&print_api_error_end_exit(90, "You Are Not Permitted To Barge Call 1 " . &_(""));
			
		}
		
		$sql="SELECT 1, extension_uuid from v_extensions where extension='$from_ext' and user_context='$domain_name'";
		warn $sql;
		%data_2 = &database_select_as_hash($sql,"extension_uuid");
		$extension_uuid=$data_2{1}{extension_uuid};
		
		$sql="SELECT 1, user_uuid from v_extension_users where user_uuid='$user_uuid' and extension_uuid='$extension_uuid'";
		warn $sql;
		%data_3 = &database_select_as_hash($sql,"user_uuid");
		$user_uuid_final=$data_3{1}{user_uuid};

		if (!$user_uuid_final) {

			$response{stat}        = 'fail';
			&print_api_error_end_exit(90, "You Are Not Permitted To Barge Call 2 " . &_(""));
			
		}
		
		$sql="SELECT 1, group_name from v_group_users where user_uuid='$user_uuid_final' and group_name='Supervisor_With_Barge'";
		warn $sql;
		%data_4 = &database_select_as_hash($sql,"group_name");
		$group_name=$data_4{1}{group_name};
		
	#	if (!$group_name) {

	#		$response{stat}        = 'fail';
	#		&print_api_error_end_exit(90, "You Are Not Permitted To Barge Call 3 " . &_(""));
			
	#	}
		
		$sql="SELECT 1, group_permission_uuid from v_group_permissions where permission_name = 'Enabled_call_barge' and group_name='Supervisor_With_Barge'";
		warn $sql;
		%data_4 = &database_select_as_hash($sql,"group_permission_uuid");
		$group_permission_uuid=$data_4{1}{group_permission_uuid};
				
		if (!$group_permission_uuid) {

			$response{stat}        = 'fail';
			&print_api_error_end_exit(90, "You Are Not Permitted To Barge Call  4" . &_(""));
			
		}

		if (!$domain{name}) {
			&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
		}
		
		$result =  &runswitchcommand('internal', "originate {origination_caller_id_number=$from_ext,domain_uuid=$domain{uuid},extension_uuid='$extension_uuid',domain_name=$domain_name,ignore_early_media=true}loopback/$from_ext/$domain_name/XML *32$barge_ext XML $domain_name");

		$response{stat}        = 'ok';
		$response{status}        = $result;
		$response{timestamp} = time;
		
		&print_json_response(%response);
}

##########################################################


##########################################################
#########date:25-May-2021
#######developed by : Hemant Chaudhari
#######purpose :- call_barge_speak_manager_to_customer (Eavesdrop)

sub call_barge_speak_manager_to_customer()
{
	local $manager_ext 	= &database_clean_string(substr $form{manager_ext}, 0, 50);
	%domain    = &get_domain();
	$domain_name    = $domain{name};

		if ($manager_ext) {
			$user_data = "user_data $manager_ext\'@\'$domain_name attr id";
			$result =  &runswitchcommand('internal', $user_data);			
			$result_1 = substr($result, 1, 3);
			
			$user_data_1 = "show channels like $result\'@\'";
			$result_ch =  &runswitchcommand('internal', $user_data_1);
			
			$channel_result = $variable = join('',split(/\n/,$result_ch));
			
			if($channel_result eq '0 total.') {
				&print_api_error_end_exit(90, "manager_ext channel not exists!" . &_(""));
			}
			
			if($result_1 eq 'ERR') {
				&print_api_error_end_exit(90, "manager_ext not exists!" . &_(""));
			}
			
			if (!$result) {
				&print_api_error_end_exit(90, "manager_ext not exists!" . &_(""));
			}
			
		}
		
	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}
	
	$result =  &runswitchcommand('internal', "luarun /usr/share/freeswitch/scripts/call_barge_send_dtmf.lua '$manager_ext' '$domain_name' 1");

	$response{stat}        = 'ok';
	$response{status}        = $result;
	$response{timestamp} = time;
	
	&print_json_response(%response);
}

##########################################################

##########################################################
#########date:25-May-2021
#######developed by : Hemant Chaudhari
#######purpose :- call_barge_speak_manager_to_agent (Eavesdrop)

sub call_barge_speak_manager_to_agent()
{
	local $manager_ext 	= &database_clean_string(substr $form{manager_ext}, 0, 50);
	%domain    = &get_domain();
	$domain_name    = $domain{name};
	
		if ($manager_ext) {
			$user_data = "user_data $manager_ext\'@\'$domain_name attr id";
			$result =  &runswitchcommand('internal', $user_data);			
			$result_1 = substr($result, 1, 3);
			
			$user_data_1 = "show channels like $result\'@\'";
			$result_ch =  &runswitchcommand('internal', $user_data_1);
			
			$channel_result = $variable = join('',split(/\n/,$result_ch));
			
			if($channel_result eq '0 total.') {
				&print_api_error_end_exit(90, "manager_ext channel not exists!" . &_(""));
			}
			
			if($result_1 eq 'ERR') {
				&print_api_error_end_exit(90, "manager_ext not exists!" . &_(""));
			}
			
			if (!$result) {
				&print_api_error_end_exit(90, "manager_ext not exists!" . &_(""));
			}
			
		}
	
	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}
	
	$result =  &runswitchcommand('internal', "luarun /usr/share/freeswitch/scripts/call_barge_send_dtmf.lua '$manager_ext' '$domain_name' 2");

	$response{stat}        = 'ok';
	$response{status}        = $result;
	$response{timestamp} = time;
	
	&print_json_response(%response);
}

##########################################################

##########################################################
#########date:25-May-2021
#######developed by : Hemant Chaudhari
#######purpose :- call_barge_three_way (Eavesdrop)

sub call_barge_three_way()
{
	local $manager_ext 	= &database_clean_string(substr $form{manager_ext}, 0, 50);
	%domain    = &get_domain();
	$domain_name    = $domain{name};
	
	if ($manager_ext) {
		$user_data = "user_data $manager_ext\'@\'$domain_name attr id";
		$result =  &runswitchcommand('internal', $user_data);			
		$result_1 = substr($result, 1, 3);
		
		$user_data_1 = "show channels like $result\'@\'";
		$result_ch =  &runswitchcommand('internal', $user_data_1);
		
		$channel_result = $variable = join('',split(/\n/,$result_ch));
		
		if($channel_result eq '0 total.') {
			&print_api_error_end_exit(90, "manager_ext channel not exists!" . &_(""));
		}
		
		if($result_1 eq 'ERR') {
			&print_api_error_end_exit(90, "manager_ext not exists!" . &_(""));
		}
		
		if (!$result) {
			&print_api_error_end_exit(90, "manager_ext not exists!" . &_(""));
		}
		
	}
		
	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}
	
	$result =  &runswitchcommand('internal', "luarun /usr/share/freeswitch/scripts/call_barge_send_dtmf.lua '$manager_ext' '$domain_name' 3");

	$response{stat}        = 'ok';
	$response{status}        = $result;
	$response{timestamp} = time;
	
	&print_json_response(%response);
}

##########################################################

##########################################################
#########date:25-May-2021
#######developed by : Hemant Chaudhari
#######purpose :- call_barge_restore_eavesdrop (Eavesdrop)

sub call_barge_restore_eavesdrop()
{
	local $manager_ext 	= &database_clean_string(substr $form{manager_ext}, 0, 50);
	%domain    = &get_domain();
	$domain_name    = $domain{name};
	
		if ($manager_ext) {
			$user_data = "user_data $manager_ext\'@\'$domain_name attr id";
			$result =  &runswitchcommand('internal', $user_data);			
			$result_1 = substr($result, 1, 3);
			
			$user_data_1 = "show channels like $result\'@\'";
			$result_ch =  &runswitchcommand('internal', $user_data_1);
			
			$channel_result = $variable = join('',split(/\n/,$result_ch));
			
			if($channel_result eq '0 total.') {
				&print_api_error_end_exit(90, "manager_ext channel not exists!" . &_(""));
			}
			
			if($result_1 eq 'ERR') {
				&print_api_error_end_exit(90, "manager_ext not exists!" . &_(""));
			}
			
			if (!$result) {
				&print_api_error_end_exit(90, "manager_ext not exists!" . &_(""));
			}
			
		}
		
	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}
	
	$result =  &runswitchcommand('internal', "luarun /usr/share/freeswitch/scripts/call_barge_send_dtmf.lua '$manager_ext' '$domain_name' 0");

	$response{stat}        = 'ok';
	$response{status}        = $result;
	$response{timestamp} = time;
	
	&print_json_response(%response);
}

##########################################################

#########date:30-Dec-2020
#######developed by : Atul Akabari
#######purpose :- Get extension base recording list 
sub get_pre_recorded_vm_list()
{

	local $ext 	= &database_clean_string(substr $form{src}, 0, 50);
	%domain    = &get_domain();
	$domain_name    = $domain{name};

	#%hash=  &database_select_as_hash("select pre_vm.pre_recorded_voicemail_uuid,pre_vm.recordings_filename from v_pre_recorded_voicemails pre_vm,v_extensions v_ext where v_ext.extension_uuid=pre_vm.extension_uuid and v_ext.extension='$ext' and accountcode='$domain_name' 

	%hash=  &database_select_as_hash("select pre_vm.pre_recorded_voicemail_uuid,pre_vm.recordings_filename from v_pre_recorded_voicemails pre_vm,v_extensions v_ext where v_ext.extension_uuid=pre_vm.extension_uuid and v_ext.extension='$ext' and v_ext.accountcode='$domain_name' and v_ext.domain_uuid='$domain{uuid}' 
		",'recordings_filename,recording_uuid');

	$list  = [];
	for (sort {$hash{$a}{recordings_filename} cmp $hash{$b}{recordings_filename}} keys %hash) {
		#  push @$list, {recording_uuid => $_,recording_name => $hash{$_}{recording_name}};
		push @$list, {recording_uuid => $_,recordings_filename => $hash{$_}->{recordings_filename}};

	}

	$response{stat}        = 'ok';
	$response{data}{recording}=$list;
	&print_json_response(%response);
}

##############################################
#############################################
###########Date :01-01-2021 
###########Developed by : Atul Akabari
########## Purpose :- Save the recording and map with the extension 
sub set_pre_recorded_vm_to_extension()
{
	local $ext 	= &database_clean_string(substr $form{src}, 0, 50);
	local $recording_uuid 	= &database_clean_string(substr $form{recording_uuid}, 0, 50);
	%domain    = &get_domain();
	$domain_name    = $domain{name};
	use DBI;

	$dbh = DBI->connect($app{database_dsn}, $app{database_user}, $app{database_password});
	use DBD::Pg qw(:pg_types);
	$sth = $dbh->prepare("UPDATE v_extensions set pre_recorded_voicemail_uuid='$recording_uuid',pre_recorded_voicemail_enabled='true' where v_extensions.accountcode='$domain_name' and v_extensions.extension='$ext'");
	$sth->execute();
	$response{stat}        = 'ok';
	$response{status}        ="Pre recorded VM configured successfully";
	&print_json_response(%response);
}
################################################
############ date :01-01-2021
############Developed by : Atul Akabari
#########Purpose : Rename the voicemail recording name

sub rename_pre_recoded_vm_filename()
{

	local $ext      = &database_clean_string(substr $form{src}, 0, 50);
	local $recording_uuid   = &database_clean_string(substr $form{recording_uuid}, 0, 50);
	local $new_file_name    = &database_clean_string(substr $form{new_file_name}, 0, 50);
	local $recording_name    = &database_clean_string(substr $form{recording_name}, 0, 50);
	%domain    = &get_domain();
	$domain_name    = $domain{name};

	if(($new_file_name =~ /\.mp3$/i)||($new_file_name =~/\.wav$/i)) {

		$sql="SELECT 1, recordings_filename from v_pre_recorded_voicemails where pre_recorded_voicemail_uuid='$recording_uuid'";
		warn $sql;
		%data = &database_select_as_hash($sql,"recordings_filename");
		$old_file_name=$data{1}{recordings_filename};

		$old_name="/var/lib/freeswitch/recordings/$domain_name/pre_recorded_vm/$old_file_name";
		$new_name="/var/lib/freeswitch/recordings/$domain_name/pre_recorded_vm/$new_file_name";
		move($old_name, $new_name);
		use DBI;
		$dbh = DBI->connect($app{database_dsn}, $app{database_user}, $app{database_password});
		use DBD::Pg qw(:pg_types);
		$sth = $dbh->prepare("UPDATE v_pre_recorded_voicemails set recordings_filename='$new_file_name' ,recording_name='$recording_name' where v_pre_recorded_voicemails.pre_recorded_voicemail_uuid='$recording_uuid'");
		$sth->execute();

		$response{status}        ="Recording File name renamed successfully";
	}
	else
	{

		$response{status}        ="Please enter valid audio file format like .wav or .mp3";
	}
	$response{stat}        = 'ok';
	&print_json_response(%response);
}


sub rename_pre_recoded_vm_filename_orig()
{

	local $ext 	= &database_clean_string(substr $form{src}, 0, 50);
	local $recording_uuid 	= &database_clean_string(substr $form{recording_uuid}, 0, 50);
	local $new_file_name 	= &database_clean_string(substr $form{new_file_name}, 0, 50);
	%domain    = &get_domain();
	$domain_name    = $domain{name};


	$sql="SELECT 1, recordings_filename from v_pre_recorded_voicemail where recording_uuid='$recording_uuid'";
	warn $sql;
	%data = &database_select_as_hash($sql,"recordings_filename");
	$old_file_name=$data{1}{recordings_filename};

	$old_name="/var/lib/freeswitch/recordings/$domain_name/pre_recorded_vm/$old_file_name";
	$new_name="/var/lib/freeswitch/recordings/$domain_name/pre_recorded_vm/$new_file_name";
	move($old_name, $new_name);	
	use DBI;
	$dbh = DBI->connect($app{database_dsn}, $app{database_user}, $app{database_password});
	use DBD::Pg qw(:pg_types);
	$sth = $dbh->prepare("UPDATE v_pre_recorded_voicemail set recordings_filename='$new_file_name'  where v_pre_recorded_voicemail.recording_uuid='$recording_uuid'");
	$sth->execute();

	$response{stat}        = 'ok';
	$response{status}        ="Recording File name renamed successfully";
	&print_json_response(%response);
}

######################################################
######Date :28-Jan-2021 
#### Developed By : Atul Akabari
######Purpose :- Enabled or diabled the pre-recorded voicemail from the extension
sub pre_recording_vm_enabled_or_disabled()
{


	local $ext      = &database_clean_string(substr $form{src}, 0, 50);
	local $is_enabled      = &database_clean_string(substr $form{is_enabled}, 0, 50);
	%domain    = &get_domain();
	$domain_name    = $domain{name};

	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}

	$sql="SELECT 1,count(*) as extension_check from v_extensions where domain_uuid='$domain{uuid}' and extension='$ext'";
	warn $sql;
	%data = &database_select_as_hash($sql,"extension_check");
	$ext_check=$data{1}{extension_check};
	if ($ext_check =='1')
	{
		use DBI;
		$dbh = DBI->connect($app{database_dsn}, $app{database_user}, $app{database_password});
		use DBD::Pg qw(:pg_types);
		if ($is_enabled eq "true" || $is_enabled eq "TRUE" || $is_enabled eq "True")
		{
			$is_enabled_val='true';
			$is_update='true';
		}
		elsif ($is_enabled eq "false" || $is_enabled eq "FALSE" || $is_enabled eq "False")
		{
			$is_enabled_val='false';
			$is_update='true';
		}
		else
		{
			$response{is_enabled}        = 'Please enter valid value like true/false';
		}
		if ($is_update eq "true")
		{		
			$sth = $dbh->prepare("UPDATE v_extensions set pre_recorded_voicemail_enabled='$is_enabled_val'  where domain_uuid='$domain{uuid}' and extension='$ext'");
			$sth->execute();
			$response{status}        = 'We have successfully configured '.$is_enabled_val.' for '.$ext;
		}
	}
	else{

		$response{ext}        ="We are not able to find the extension on this domain so please enter valid extension number";
	}	

	$response{stat}        = 'ok';
	&print_json_response(%response);

}

#############END##############
#############################################
#Date : 19-10-2020 
#developed by : Atul Akabari
#Purpose : get contact/directory list based on the domain 

sub get_contactbook()
{

	local ($domain_name) = &database_clean_string($form{domain});

	%domain         = &get_domain();
	if (!$domain{name}) {
		&print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}

	%hash=  &database_select_as_hash(
		"select extension, directory_first_name from v_domains,v_extensions where v_domains.domain_uuid = v_extensions.domain_uuid and v_domains.domain_name='$domain_name' ",'extension,directory_first_name');


	$list  = [];
	for (sort {$hash{$a}{extension} cmp $hash{$b}{extension}} keys %hash) {
		push @$list, {phonenumber => $_,name => $hash{$_}{extension},extension => $_.'@'.$domain };

	}

	$response{stat} = 'ok';
	$response{data}{phonebook}=$list;

	&print_json_response(%response);   
}
######## End ####### 
########Date :-29-Jan-2021
#Developed By : Atul Akabari
#purpose :- For get contact list with some additional information
#
sub get_contactbook_new()
{

	local ($domain_name) = &database_clean_string($form{domain});

	%domain         = &get_domain();
	if (!$domain{name}) {
		&print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}

	%hash=  &database_select_as_hash(
		"select extension, directory_full_name from v_domains,v_extensions where v_domains.domain_uuid = v_extensions.domain_uuid and directory_visible='true' and directory_exten_visible='true' and v_domains.domain_name='$domain_name' ",'extension,directory_full_name');


	$list  = [];
	for (sort {$hash{$a}{extension} cmp $hash{$b}{extension}} keys %hash) {
		#push @$list, {phonenumber => $_,name => $hash{$_}{extension},extension => $_.'@'.$domain };
		push @$list, {directory_exten_visible =>'true',directory_visible =>'true',extension=>$hash{$_}{extension}.' '.$_,};

	}

	$response{stat} = 'ok';
	$response{data}{phonebook}=$list;

	&print_json_response(%response);   
}

#################END############
sub getchannelstate () {
	local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);

	%channels = &parse_channels();

	$state   = $channels{$uuid}{callstate};

	$response{stat}        = 'ok';
	$response{data}{state} = $state;


	&print_json_response(%response);   
}

######################################
#Date : 14/10/2020
#Developed by : Atul Akabari
#Purpose: for get attended transfer feature info of all channles

sub getchannelstatedetailinfo () {
	local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);

	$uuid_xtt = &runswitchcommand('internal', "uuid_getvar $uuid uuid_xtt");
	%calls = &parse_calls();
	$agent2_data=$calls{$uuid}{b_uuid};

	%channels = &parse_channels();
	$state   = $channels{$uuid}{callstate};
	$response{stat}        = 'ok';
	#$response{data}{state} = $state;

	# Added by Atul for get All user status

	$agent1= $channels{$uuid}{callstate};
	$client= $channels{$uuid_xtt}{callstate};
	$agent2= $channels{$calls{$uuid}{b_uuid}}{callstate};

	$list = [];
	if($uuid)
	{
		$ext= &runswitchcommand('internal',"uuid_getvar $uuid sip_to_user");
		push @$list, { number=> $ext ,uuid => $uuid ,state=>$agent1 };
	}
	if($client)
	{

		$client_ext= &runswitchcommand('internal',"uuid_getvar $uuid_xtt sip_to_user");
		push @$list, { number=> $client_ext,uuid => $uuid_xtt,state=>$client };
	}


	if($agent2_data ne $uuid_xtt)
	{
		$agent2_ext= &runswitchcommand('internal',"uuid_getvar $calls{$uuid}{b_uuid} sip_to_user");
		if($calls{$uuid}{b_uuid} ne '')
		{
			push @$list, { number=> $agent2_ext,uuid => $calls{$uuid}{b_uuid},state=>$agent2 };
		}
	}

	$response{data}{states}=$list;
	&print_json_response(%response);   

}

#####  End  ########
###################################################################
#Date :14-12-2020 
#Developed by  : Added by Atul 
#Purpose : for getconferencecalldetails
###################################################################

sub getconferencecalldetails
{

	%response       = ();  
	$name   = &database_clean_string(substr $form{conference_name}, 0, 10);

	%domain         = &get_domain();
	$domain_name    = $domain{name};
	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}

	$output = &runswitchcommand('internal', "conference $name json_list");

	$conf_check="-ERR Conference $name not found\n";

	if($output eq $conf_check)
	{
		$response{conference_status} = "Conference not found";
	}
	else
	{
		my $objects = JSON->new->utf8->decode($output);
		$member_cnt = $objects->[0]->{member_count};
		%channels = &parse_channels();

		$list = [];
		if($member_cnt >0 )
		{
			my @member=$objects->[0]->{members};
			foreach my $obj ( @member) 
			{
				for($i=0;$i<$member_cnt;$i++)
				{
					#push @$list, {uuid =>$obj->[$i]->{uuid},number=> $obj->[$i]->{caller_id_number},state=>$channels{$obj->[$i]->{uuid}}{callstate}};
					push @$list, {uuid =>$obj->[$i]->{uuid},number=> &runswitchcommand('internal',"uuid_getvar $obj->[$i]->{uuid} RDNIS"),state=>$channels{$obj->[$i]->{uuid}}{callstate}};
				}

			}
		}else
		{
			$response{data}="Conference not running";
		}
		$response{data}{states}=$list;
	}
	$response{stat} = 'ok';
	&print_json_response(%response); 

}


###########################   END   ###############################
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
	$response{message} = $output;   

	&print_json_response(%response);
}


sub makeautocall {
	local $ext 	= &database_clean_string(substr $form{src}, 0, 50);

	%domain         = &get_domain();
	$domain_name    = $domain{name};
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

	$is_widget_in_conference = 0;
	$conf_list = &runswitchcommand('internal', "conference $ext list");
	for (split /\n/, $conf_list) {
		if (index($_, "loopback/$ext-a") != -1) {
			$is_widget_in_conference = 1;
			last;
		}
	}
	$result = &runswitchcommand('internal', "conference $ext kick non_moderator");

	if (!$is_widget_in_conference) {
		$result =  &runswitchcommand('internal', "originate {origination_caller_id_name=callback-$ext,origination_caller_id_number=$cid,domain_name=$domain_name,ignore_early_media=true,origination_uuid=$uuid,flags=endconf|moderator}loopback/$ext/$domain_name/XML conference$ext XML default");
		sleep 2;

		$call_list = &runswitchcommand('internal', "show calls");
		$is_ext_answered = 0;
		for (split /\n/, $call_list) {
			if (index($_, "$uuid,") == 0) {
				$is_ext_answered = 1;
				last;
			}
		}

		if (!$is_ext_answered) {
			&print_api_error_end_exit(140, "ext not answered");
		}
	}


	$uuid = &genuuid();
	$result = &runswitchcommand('internal', "bgapi originate {origination_caller_id_name=callback-$ext,origination_caller_id_number=$cid,domain_name=$domain_name,origination_uuid=$uuid,autocallback_fromextension=$ext,is_lead=1}loopback/$dest/$domain_name/XML conference$ext XML default");

	$response{stat}       = 'ok';
	$response{data}{uuid} = $uuid;
	&print_json_response(%response);
}

sub get_incoming_event {
	local $ext = $form{ext};
	%domain         = &get_domain();
	$domain_name    = $domain{name};
	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}


	$ext = "$ext\@$domain";

	use Cache::Memcached;
	local $memcache = "";
	$memcache = new Cache::Memcached {'servers' => ['127.0.0.1:11211'],};

	$memcache->delete($ext);

	local $starttime = time;
	local $| = 1;

	print $cgi->header(-type  =>  'text/event-stream', '-cache-control' => 'NO-CACHE',);

	CHECK:

	if (time - $starttime > 3600) {
		$memcache->delete($ext);
		exit 0; #force max connection time to 1h
	}

	local $status = $memcache->get($ext);
	local $current_state = '';

	local $channels = &runswitchcommand('internal', 'show channels');
	local $cnt      = 0;
	for  $line (split /\n/, $channels) {
		my @f = split ',', $line;
		if ($f[22] eq $ext && $f[33] ) { #presence_id && initial_ip_addr

			$current_state = $f[24];
			if ($status ne $current_state) {		
				print "data:", &Hash2Json(error => '0', 'message' => 'ok', 'actionid' => $query{actionid}, uuid => $f[0],
					caller => "$f[6] <$f[7]>", start_time => $f[2], current_state => $f[24]), "\n\n";
				$memcache->set($ext, $current_state);
			}
		}		
	}

	if (!$current_state) {
		if (!$status) {

			print "data:" , &Hash2Json(error => '0', 'message' => 'ok', 'actionid' => $query{actionid}, uuid => '',
				caller => "", start_time => '', current_state => 'nocall'), "\n\n";
			$memcache->set($ext, 'nocall');
		} elsif ($status ne 'nocall') {
			print "data:", &Hash2Json(error => '0', 'message' => 'ok', 'actionid' => $query{actionid}, uuid => '',
				caller => "", start_time => '', current_state => 'hangup'), "\n\n";
			$memcache->set($ext, '');
		}
	}

	sleep 1;
	goto CHECK;
}

sub hold () {
	local ($uuid) = &database_clean_string(substr $form{uuid}, 0, 50);
	local  $direction = $form{direction} eq 'inbound' ? 'inbound': 'outbound';

	%calls = parse_calls();
	if ($direction eq 'inbound') {		
		for  (keys %calls) {
			$uuid_xtt =  $_ if $calls{$_}{b_uuid} eq $uuid;
		}
	} else {
		$uuid_xtt = $calls{$uuid}{b_uuid};	
	}

	if (!$uuid_xtt) {
		warn "$uuid not in any calls!";
		&print_api_error_end_exit(160, "$uuid not in any $direction calls");
	}

	$output = &runswitchcommand("internal", "uuid_hold toggle $uuid_xtt");

	$response{stat}          = 'ok';
	$response{message} = $output;
	&print_json_response(%response);
}

sub unhold() {
	&hold();
}

sub agentlogin () {
	$name   = &database_clean_string(substr $form{agentname}, 0, 50);
	$status = shift || 'Available';
	$break_type= shift || 'Available';
	$current_time=strftime('%H:%M:%S',localtime);	
	%domain      = &get_domain();
	$domain_name = $domain{name};
	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}

	
	#local $sql = "SELECT 1,dynamic_callerid FROM v_extensions where extension = '$ext' and domain_uuid = '$domain_uuid' limit 1";
	local $sql = "SELECT 1,call_center_agent_uuid from v_call_center_agents where domain_uuid='$domain{uuid}' and agent_id='$name' limit 1";
	local %data = &database_select_as_hash($sql, "call_center_agent_uuid");

	
	##warn "callcenter_config agent set status $name\@$domain_name '$status'";
	###$output = &runswitchcommand(1, "callcenter_config agent set status $name\@$domain_name '$status'");
	$user=$data{1}{call_center_agent_uuid};
	$output = &runswitchcommand(1, "callcenter_config agent set status $user '$status'");
	### Date :03-04-2024

	local $sql1="SELECT 1, call_center_agents_punch_time_uuid from v_call_center_agents_punch_times where call_center_agent_uuid='$user' and domain_uuid='$domain{uuid}' and punch_out is NULL ";
	local %data_check= &database_select_as_hash($sql1,"call_center_agents_punch_time_uuid");
	$user_punch_id=$data_check{1}{call_center_agents_punch_time_uuid};
	if($user_punch_id)
	{
	use DBI;
        $dbh = DBI->connect($app{database_dsn}, $app{database_user}, $app{database_password});
        use DBD::Pg qw(:pg_types);
        $sth = $dbh->prepare("UPDATE v_call_center_agents_punch_times set punch_out='$current_time',update_date=now(),update_user='$user'  where domain_uuid='$domain{uuid}' and call_center_agents_punch_time_uuid='$user_punch_id'");
        $sth->execute();
	$uuid = &genuuid();
            &database_do("insert into
                            v_call_center_agents_punch_times
                            (call_center_agents_punch_time_uuid,call_center_agent_uuid,domain_uuid,user_uuid,agent_punch_status,punch_in,insert_date,insert_user)
                          values
                            ('$uuid','$user','$domain{uuid}','$user','$break_type','$current_time',now(),'$user')"
                        );

	
	}else {
	$uuid = &genuuid();
            &database_do("insert into
                            v_call_center_agents_punch_times
                            (call_center_agents_punch_time_uuid,call_center_agent_uuid,domain_uuid,user_uuid,agent_punch_status,punch_in,insert_date,insert_user)
                          values
                            ('$uuid','$user','$domain{uuid}','$user','$break_type','$current_time',now(),'$user')"
                        );
}
	## END 
	$response{stat}          = 'ok';
	$response{message} = $output;
	$response{agent_status} = $break_type;
	&print_json_response(%response);
}

sub agentlogout () {
	&agentlogin('Logged Out','Logged Out');
}

sub agentbreak()
{
		
	$break_type   = &database_clean_string(substr $form{break_type}, 0, 50);
	####&agentlogin('On Break');
	&agentlogin('On Break' ,$break_type);
}
#############Added by Atul 13-07-2023 get Agent status
sub getagentstatus()
{
	$name   = &database_clean_string(substr $form{agentname}, 0, 50);
	%domain      = &get_domain();
	$domain_name = $domain{name};
	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}

		
	local $sql = "SELECT 1,call_center_agent_uuid from v_call_center_agents where domain_uuid='$domain{uuid}' and agent_id='$name' limit 1";
	local %data = &database_select_as_hash($sql, "call_center_agent_uuid");
	
	$user=$data{1}{call_center_agent_uuid};
	$output = &runswitchcommand(1, "callcenter_config agent get status $user");
	
	$response{stat}          = 'ok';
	$response{message} = $output;
	&print_json_response(%response);
}
####END ########
### Date : 22/09/23 Added by Atul for extension based enabled disable dynamic caller id
sub extension_dynamic_callerid()
{

        $extension   = &database_clean_string(substr $form{extension}, 0, 50);
	$status   = &database_clean_string(substr $form{status}, 0, 50);
        %domain      = &get_domain();
        $domain_name = $domain{name};
        if (!$domain{name}) {
                &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
        }
	
	local $sql = "SELECT 1,count(*) as extension_check from v_extensions where domain_uuid='$domain{uuid}' and extension='$extension' limit 1";
	local %data = &database_select_as_hash($sql, "extension_check");
	$ext_check=$data{1}{extension_check};
	
	if ($ext_check =='1')
	{
	use DBI;
	$dbh = DBI->connect($app{database_dsn}, $app{database_user}, $app{database_password});
	use DBD::Pg qw(:pg_types);
        $sth = $dbh->prepare("UPDATE v_extensions set dynamic_callerid='$status'  where domain_uuid='$domain{uuid}' and extension='$extension'");
	$sth->execute();
	$response{message} = "Dynamic callerid updated successfully";
	}
	else
	{
		$response{message} = "Extension not found";
	}
        $response{stat}          = 'ok';
        &print_json_response(%response);
}

###END
##### Date : 22/09/23 Added by Atul for tenant based dyamic caller id 
sub tenant_based_dynamic_caller_id()
{
	
        $domain_name1   = &database_clean_string(substr $form{domain}, 0, 50);
	$status   = &database_clean_string(substr $form{status}, 0, 50);
        %domain      = &get_domain();
        $domain_name = $domain{name};
        if (!$domain{name}) {
                &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
        }
	
	local $sql = "SELECT 1,count(*) as domain_name from v_domains where domain_name='$domain_name1' limit 1";
	local %data = &database_select_as_hash($sql, "domain_name");
	$domain_check=$data{1}{domain_name};

	if ($domain_check =='1')
        {
        use DBI;
        $dbh = DBI->connect($app{database_dsn}, $app{database_user}, $app{database_password});
        use DBD::Pg qw(:pg_types);
        $sth = $dbh->prepare("UPDATE v_domains set dynamic_callerid='$status'  where domain_name='$domain_name1'");
        $sth->execute();
        $response{message} = "Dynamic callerid updated successfully";
        }
        else
        {
                $response{message} = "Domain name not found";
        }

	
		
        $response{stat}          = 'ok';
        &print_json_response(%response);
}

##### END 
 
############Date : 24/08/23 Added for manage user presence_status

sub presencestatus()
{
        $name   = &database_clean_string(substr $form{agentname}, 0, 50);
	$status   = &database_clean_string(substr $form{status}, 0, 50);
        %domain      = &get_domain();
        $domain_name = $domain{name};
        if (!$domain{name}) {
                &print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
        }


        local $sql = "SELECT 1,call_center_agent_uuid from v_call_center_agents where domain_uuid='$domain{uuid}' and agent_id='$name' limit 1";
        local %data = &database_select_as_hash($sql, "call_center_agent_uuid");

        $user=$data{1}{call_center_agent_uuid};

		use DBI;
		$dbh = DBI->connect($app{database_dsn}, $app{database_user}, $app{database_password});
		use DBD::Pg qw(:pg_types);
        
		$sth = $dbh->prepare("UPDATE v_call_center_agents set presence_out='$status'  where domain_uuid='$domain{uuid}' and call_center_agent_uuid='$user'");
                 $sth->execute();

        $response{stat}          = 'ok';
        $response{message} = "Presence status updated successfully";
        &print_json_response(%response);
}
####END ########


sub stoprecording() {
	&_dorecording(0);
}

sub startrecording() {
	&_dorecording(1);
}
sub _dorecording() {
	local $mode = shift;
	local $ext = $form{ext} || $form{extension};
	%domain    = &get_domain();
	$domain_name    = $domain{name};
	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}


	$ext = "$ext\@$domain";
	%raw_calls = &parse_calls();
	for (keys %raw_calls) {
		if ($raw_calls{$_}{presence_id} eq $ext) {
			$found = 1;
			$direction = 'outbound';

		}

		if ($raw_calls{$_}{b_presence_id} eq $ext) {
			$found = 1;
			$direction = 'inbound';			
		}


		if ($found) {
			$uuid = $_;
			$time = $raw_calls{$_}{created_epoch};

			last;
		}

	}

	if (!$found) {
		$response{stat}    = 'fail';
		$response{message} = '$ext is not in any bridged call';
	} else {
		if (!$mode) {
			$output = &runswitchcommand('internal', "uuid_record $main_uuid stop all");
		} else {

			$year = strftime('%Y', localtime);
			$mon  = strftime('%b', localtime);
			$day  = strftime('%d', localtime);

			$recording_file = "/usr/local/freeswitch/recordings/$domain_name/archive/$year/$mon/$day/$uuid.$record_format";
			for $i (0..20) {
				$tmp_recording_file = "/usr/local/freeswitch/recordings/$domain_name/archive/$year/$mon/$day/$uuid" . ($i ? "_$i":"") . ".$record_format";
				if (!-e $tmp_recording_file) {
					$recording_file = $tmp_recording_file;
					last;
				}			
			}

			$output = &runswitchcommand('internal', "uuid_record $uuid start $recording_file");
		}	
		$response{stat}    = 'ok';
		$response{message} = $output;
	}

	&print_json_response(%response);

}



sub getuuid() {
	#try best to get call uuid by different condition
}

sub get_bchannel_uuid() {
	local $uuid = shift || return;
	%raw_calls = &parse_calls();
	for (keys %raw_calls) {
		if ($_ eq $uuid) {
			return $raw_calls{$_}{b_uuid};
			last;
		}
	}

	return;
}

sub _get_dynamic_callerid() {
	local ($ext, $domain_uuid, $code) = @_;
	local $sql = "SELECT 1,dynamic_callerid FROM v_extensions where extension = '$ext' and domain_uuid = '$domain_uuid' limit 1";
	local %data = &database_select_as_hash($sql, "dynamic_callerid");

	#return unless $data{1}{dynamic_callerid} and $data{1}{dynamic_callerid} eq 'true';
	if ($data{1}{dynamic_callerid} eq 'true') {
		$sql = "SELECT 1, destination_number FROM v_destinations where destination_number like '$code%' and domain_uuid = '$domain_uuid' and destination_enabled='true' and destination_inbound_type='dynamic' limit 1";
		warn $sql;
		%data = &database_select_as_hash($sql, "destination_number");
		# Date 10-09-2020 Added by Atul for if dynamic caller id enabled and not match area code then that value selectd 

		##if ($data{1}{destination_number}=='000000000')	
		##{
		##	$sql = "SELECT 1, domain_setting_value FROM v_domain_settings WHERE domain_uuid = '$domain_uuid' AND domain_setting_subcategory = 'tenant_outbound_caller_id_number' AND domain_setting_enabled ='true' LIMIT 1";
		##	warn $sql;
		##	%data = &database_select_as_hash($sql, "domain_setting_value");
		##	return $data{1}{domain_setting_value};
		##}
		return $data{1}{destination_number};

# Date 09-09-2020 Added by Atul for DCID logic
	} else {

		# Date :29-09-2020 Added by Atul for check outbound caller id number 
		$sql="SELECT 1 ,outbound_caller_id_number FROM v_extensions WHERE domain_uuid = '$domain_uuid' and extension ='$ext'";
		warn $sql;
		%data = &database_select_as_hash($sql, "outbound_caller_id_number");
		#return $data{1}{outbound_caller_id_number};
		$cid_value=$data{1}{outbound_caller_id_number};
		if ($data{1}{outbound_caller_id_number} eq '')
		{
			$sql = "SELECT 1, domain_setting_value FROM v_domain_settings WHERE domain_uuid = '$domain_uuid' AND domain_setting_subcategory = 'tenant_outbound_caller_id_number' AND domain_setting_enabled ='true' LIMIT 1";
			warn $sql;
			%data = &database_select_as_hash($sql, "domain_setting_value");
			$cid_value= $data{1}{domain_setting_value};
			
		}
		return $cid_value;
	}	
# end


}


sub _get_area_code() {
	local ($number) = @_;
	$number =~ s/^\+?1?//g;
	return substr($number, 0, 3);
}

sub get_ext_and_agent () {
	
local $poststring_add = '
extension_uuid:
extension:10000
call_group:
agent_name:
agent_status:Available
effective_caller_id_name:';
     
     local %post_add = ();
     for (split /\n/, $poststring_add) {
          ($key, $val) = split ':', $_, 2;
          next if !$key;
          $post_add{$key} = $val;
     }
     $fields = join ",", keys %post_add;

     $response = ();
    
     %domain   = &get_domain();
     
     if (!$domain{name}) {
          $response{stat}		= "ok";
          $response{message}	= "$domain not exists!";
     }
     
     %hash = &database_select_as_hash_with_key (
                                             "select
                                                 *,a.agent_id,a.agent_name,a.agent_status
													from
                                                 v_extensions e,v_call_center_agents a where (e.domain_uuid='$domain{uuid}' and a.agent_id=e.extension and a.domain_uuid='$domain{uuid}') or (e.domain_uuid='$domain{uuid}' and a.agent_name=e.extension and a.domain_uuid='$domain{uuid}')",
                                             'extension_uuid',
                                             "$fields,");
	 

     $response{stat}	= "ok";
     $response{message}	= "OK";
	 
	 $output = &runswitchcommand('internal', 'callcenter_config agent list');
		%agent_status = ();
		for (split /\n/, $output) {
			@cols = split /\|/;
			$agent_status{$cols[0]} = $cols[5];
			warn $cols[0], ' ==> ', $cols[5], "\n";
		}
	
     $response{data}{list} = [];
     for (sort {$hash{$a}{extension} cmp $hash{$b}{extension}} keys %hash) {
		 
          push @{$response{data}{list}}, $hash{$_};
		  if ($hash{$_}{agent_status} eq 'null') {
			  #$hash{$_}{agent_status} = '';

		  }
		 # $hash{$_}{agent_status} = $agent_status{$hash{$_}{agent_name} . '@' . $domain{name}};
		 # $hash{$_}{agent_status} = $agent_status{$hash{$_}{call_center_agent_uuid}};
		#warn Agent_status,'===>',$hash{$_}{agent_status};
		  $hash{$_}{agent_status} =~ s/\%20/ /g;
		  
		  if ($hash{$_}{agent_status} eq 'null') {
			  #$hash{$_}{agent_status} = '';
		  }
		  
		  %hash1 = &database_select_as_hash_with_key (
                                             "select
                                                 *
													from
                                                 v_extensions where domain_uuid='$domain{uuid}'",
                                             'extension_uuid',
                                             "$fields,");
		 #$response{data}{list1} = [];
		 for (sort {$hash1{$a}{extension} cmp $hash1{$b}{extension}} keys %hash1) {
			 
			 if ($hash{$_}{extension_uuid} ne $hash1{$_}{extension_uuid}) {
				 $hash{$_}{extension_uuid} = $hash1{$_}{extension_uuid};
				 $hash{$_}{effective_caller_id_name} = $hash1{$_}{effective_caller_id_name};
				 $hash{$_}{extension} = $hash1{$_}{extension};
				 $hash{$_}{call_group} = $hash1{$_}{call_group};
				 #$hash{$_}{agent_name} = '';
				 $hash{$_}{agent_status} = '';
				 push @{$response{data}{list}}, $hash{$_};
			 }
			 
		 }	
     }
     
     &print_json_response(%response);
}

sub get_livechannelslite_1 () {
	
	%domain         = &get_domain();
	$domain_name    = $domain{name};
	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}

	$show_all	= $form{show_all};
	%channels 	= &parse_channels_lite();

	for (sort {$channels{$b}{created_epoch} <=> $channels{$a}{created_epoch}} keys %channels) {
			
		my $ext = $channels{$_}{presence_id};

		my ($ext_val, undef) = split('@\s*', $ext);

		%channel = &database_select_as_hash_with_key (
										 "select
											 extension_uuid,extension,v_extensions.*
												from
											 v_extensions where domain_uuid='$domain{uuid}' and extension='$ext_val'",
										 'extension_uuid',
										 "extension_uuid");
								
		for (sort {$channel{$a}{extension_uuid} <=> $channel{$b}{extension_uuid}} keys %channel) {
			my $ext = $channels{$_}{presence_id};

			my ($ext_val, undef) = split('@\s*', $ext);
				
			if ($ext_val eq $channel{$_}{extension}){
				$extension_uuid= $channel{$_}{extension_uuid};
			}
		}
			
		if (!$show_all) {
			
			if ($channels{$_}{application} eq 'eavesdrop' or $channels{$_}{accountcode} eq $domain_name) {
				next unless $channels{$_}{accountcode} eq $domain_name;
			}else{
				next unless $channels{$_}{context} eq $domain_name;
			}
			
			if ($extension_uuid){
				$channels{$_}{extension_uuid} = $extension_uuid;
			}else{
				$channels{$_}{extension_uuid} ='';
			}
			
			push @{$response{data}{channel_list}}, $channels{$_};
		}
		
	}

	$response{stat} = 'ok';
	#$response{timestamp} = time;
	
	&print_json_response(%response);
}

sub get_livechannelslite () {
	
	%domain         = &get_domain();
	$domain_name    = $domain{name};
	if (!$domain{name}) {
		&print_api_error_end_exit(90, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
	}

	$show_all	= $form{show_all};
	%channels 	= &parse_channels_lite_1();

	for (sort {$channels{$b}{created_epoch} <=> $channels{$a}{created_epoch}} keys %channels) {
		
		if ($channels{$_}{direction} eq 'outbound' and $channels{$_}{application} ne 'eavesdrop') {
			$uuid_a = $channels{$_}{uuid};
			$cmd = `fs_cli -x 'uuid_dump $uuid_a'|grep Other-Leg-ANI`;
			my (undef,$cmd_1) = split(':\s*', $cmd);
			$cmd_O = $variable = join('',split(/\n/,$cmd_1));
		%channel = &database_select_as_hash_with_key (
									 "select
										 extension_uuid,extension,effective_caller_id_number,v_extensions.*
											from
										 v_extensions where domain_uuid='$domain{uuid}' and extension = '$cmd_O'",
									 'extension_uuid',
									 "extension_uuid");
		}elsif ($channels{$_}{direction} eq 'inbound') {
			$uuid_b = $channels{$_}{uuid};
			$app_id = $channels{$_}{application};

			#$cmd = `fs_cli -x 'uuid_dump $uuid_b'|grep variable_last_sent_callee_id_number`;
			$cmd_uuid = `fs_cli -x 'uuid_dump $uuid_b'|grep variable_extension_uuid`;
			my (undef,$cmd_2) = split(':\s*', $cmd_uuid);
			$cmd_2 = $variable = join('',split(/\n/,$cmd_2));
				
			$cmd = `fs_cli -x 'uuid_dump $uuid_b'|grep Caller-Callee-ID-Number`;
			my (undef,$cmd_1) = split(':\s*', $cmd);
			$cmd_I = $variable = join('',split(/\n/,$cmd_1));
			
			%channel = &database_select_as_hash_with_key (
									 "select
										 extension_uuid,extension,effective_caller_id_number,v_extensions.*
											from
										 v_extensions where domain_uuid='$domain{uuid}' and extension = '$cmd_I' or extension_uuid ='$cmd_2' or extension='$cmd_name_1'",
									 'extension_uuid',
									 "extension_uuid");
									 
		}elsif ($channels{$_}{direction} eq 'outbound' and $channels{$_}{application} eq 'eavesdrop') {
				$uuid_b = $channels{$_}{uuid};
				$app_id = $channels{$_}{application};
				$cmd = `fs_cli -x 'uuid_dump $uuid_b'|grep Caller-Caller-ID-Number`;
				my (undef,$cmd_ev) = split(':\s*', $cmd);
				$cmd_ev_1 = $variable = join('',split(/\n/,$cmd_ev));
				$response{cmd_name_I} = $cmd_ev_1;
				%channel = &database_select_as_hash_with_key (
									 "select
										 extension_uuid,extension,effective_caller_id_number,v_extensions.*
											from
										 v_extensions where domain_uuid='$domain{uuid}' and extension='$cmd_ev_1'",
									 'extension_uuid',
									 "extension_uuid");
		}
		
		for (sort {$channel{$a}{extension_uuid} <=> $channel{$b}{extension_uuid}} keys %channel) {
				$extension_uuid = $channel{$_}{extension_uuid};
		}
		
		my $dest_1 = $channels{$_}{dest};
		
		%channel_1 = &database_select_as_hash_with_key (
										 "select
												*
												from
											 v_call_center_queues where domain_uuid='$domain{uuid}' and queue_extension='$dest_1'",
										 'queue_name',
										 "queue_name");
										 
		for (sort {$channel_1{$a}{queue_name} <=> $channel_1{$b}{queue_name}} keys %channel_1) {
			
			my $dest_1 = $channels{$_}{dest};
						
			if ($channel_1{$_}{queue_extension} eq $dest_1 and $channel_1{$_}{queue_name} ne '' and $channels{$_}{direction} ne 'outbound') {
				$call_centre_name= $channel_1{$_}{queue_name};
			}else{
				$call_centre_name= '';
			}
		}
		
		if (!$show_all) {
			
			if ($channels{$_}{application} eq 'eavesdrop' or $channels{$_}{accountcode} eq $domain_name) {
				next unless $channels{$_}{accountcode} eq $domain_name;
			}else{
				next unless $channels{$_}{context} eq $domain_name;
			}
			
			if ($extension_uuid){
				$channels{$_}{extension_uuid} = $extension_uuid;
				my $presence_id_1 = $channels{$_}{presence_id};
				if ($presence_id_1) {
					$channels_new{$_}{ext_uuid}=$channels{$_}{extension_uuid};
				}else{
					$channels_new{$_}{ext_uuid}='';
				}
			}else{
				$channels{$_}{extension_uuid} ='';
				$channels_new{$_}{ext_uuid}= '';
			}
			
			if ($call_centre_name) {
				$channels{$_}{call_centre_name} = $call_centre_name;
				$channels_new{$_}{call_centre_name}=$channels{$_}{call_centre_name};
			}else{
				$channels{$_}{call_centre_name} ='';
				$channels_new{$_}{call_centre_name}= '';
			}
			
			$channels_new{$_}{call_uuid}=$channels{$_}{call_uuid};
			$channels_new{$_}{direction}=$channels{$_}{direction};
			$channels_new{$_}{callstate}=$channels{$_}{callstate};
			$channels_new{$_}{created_epoch}=$channels{$_}{created_epoch};
			$channels_new{$_}{uuid}=$channels{$_}{uuid};
			push @{$response{data}{channel_list_lite}}, $channels_new{$_};
			#push @{$response{data}{channel_list}}, $channels{$_};
		}
		
	}

	$response{stat} = 'ok';
	$response{timestamp} = time;
	
	&print_json_response(%response);
}

return 1;
