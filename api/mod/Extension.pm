=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut


sub addextension () {         
     local $poststring_add = '
extension:2000
number_alias:
range:1
autogen_users:
voicemail_password:1234
accountcode:pbx.fusionpbx.cn
effective_caller_id_name:
effective_caller_id_number:
outbound_caller_id_name:
outbound_caller_id_number:
emergency_caller_id_name:
emergency_caller_id_number:
directory_full_name:
directory_visible:true
directory_exten_visible:true
enabled_video_codec:false
limit_max:5
limit_destination:
voicemail_enabled:true
voicemail_mail_to:
voicemail_attach_file:true
voicemail_local_after_email:true
toll_allow:
call_timeout:30
call_group:
user_record:
hold_music:
user_context:pbx.fusionpbx.cn
auth_acl:
cidr:
missed_call_app:email
missed_call_data:
force_ping:
absolute_codec_string:
call_screen_enabled:
dynamic_callerid:
sip_force_contact:
sip_force_expires:
nibble_account:
mwi_account:
sip_bypass_media:bypass-media-after-bridge
dial_string:
enabled:true
description:
     ';
     
     local %post_add = ();
     for (split /\n/, $poststring_add) {
          ($key, $val) = split ':', $_, 2;
          next if !$key;
          $post_add{$key} = $val;
          $post_add{$key} = $form{$key} if defined $form{$key};
     }

     $response = ();
    
     %domain   = &get_domain();
     $extension = &clean_int($form{extension});

     if (!$domain{name}) {
          $response{stat}		= "fail";
          $response{message}	= "$form{domain_name}/$form{domain_uuid} not exists!";
     }
     if ($response{stat} ne 'fail') {
          %hash = &database_select_as_hash("select 1,extension_uuid from v_extensions " .
                                           "where extension='$extension' and domain_uuid='$domain{uuid}'", 'uuid');
          if ($hash{1}{uuid}) {
               $response{stat}	             	= "fail";
               $response{message}	            = "$extension already exists!";
               $response{data}{extension_uuid}  = $hash{1}{uuid};
          }
     }
     
     if ($response{stat} ne 'fail') {
          $enabled            = &get_enabled($form{enabled});
          $vm_enabled         = &get_enabled($form{vm_enabled});
          $voicemail_password = &clean_int($form{voicemail_password});
          $vm_mailto          = &database_clean_string(substr($form{vm_mailto}, 0, 50));          
          $user_context       = $domain{name};
          
          
          $post_add{extension} = $extension;
          $post_add{enabled}   = $enabled || 'true';
          $post_add{vm_enabled}= $vm_enabled || 'true';
          $post_add{voicemail_password} = $voicemail_password;
          $post_add{vm_mailto}          = $vm_mailto;
          $post_add{user_context}       = $user_context;
		#Added by Hemant Chaudhari 21-07-2021
          $post_add{enabled_video_codec}       = &get_enabled($form{enabled_video_codec}) || 'false';
		#End
		  $post_add{range}                = &clean_int($form{range}) || 1;
          $post_add{accountcode}             = $form{accountcode} || $user_context;
          $post_add{autogen_users}           = &database_clean_string($form{autogen_users});
          $post_add{directory_visible}       = &get_enabled($form{directory_visible}) || 'true';
          $post_add{directory_exten_visible} = &get_enabled($form{directory_exten_visible}) || 'true';
          $post_add{voicemail_attach_file}   = &get_enabled($form{voicemail_attach_file}) || 'true';
          $post_add{voicemail_local_after_email} = &get_enabled($form{voicemail_local_after_email}) || 'true';
          $post_add{call_timeout}                = &clean_int($form{call_timeout}) || 30;
          #Added By Hemant 16-11-2021
		  $post_add{missed_call_app}     = &database_clean_string(substr($form{missed_call_app}, 0, 10));
		  $post_add{missed_call_data}     = &database_clean_string(substr($form{missed_call_data}, 0, 50));
		  $post_add{sip_force_contact}     = &database_clean_string(substr($form{sip_force_contact}, 0, 50));
		  $post_add{sip_bypass_media}     = &database_clean_string(substr($form{sip_bypass_media}, 0, 50));
		  $post_add{force_ping}       = &get_enabled($form{force_ping}) || '';
		  $post_add{absolute_codec_string}	= &database_clean_string(substr($form{absolute_codec_string}, 0, 50));
		  $post_add{call_screen_enabled} = &get_enabled($form{call_screen_enabled}) || 'false';
		  $post_add{dynamic_callerid} = &get_enabled($form{dynamic_callerid}) || 'false';
		  #End
          $post_add{effective_caller_id_name}     = &database_clean_string(substr($form{effective_caller_id_name}, 0, 50));
          $post_add{effective_caller_id_number}   = &database_clean_string(substr($form{effective_caller_id_number}, 0, 50));
          $post_add{outbound_caller_id_number}    = &database_clean_string(substr($form{outbound_caller_id_number}, 0, 50));
          $post_add{outbound_caller_id_name}      = &database_clean_string(substr($form{outbound_caller_id_name}, 0, 50));
          $post_add{directory_full_name}          = &database_clean_string(substr($form{directory_full_name}, 0, 50));
          $post_add{voicemail_password}           = &database_clean_string(substr($form{voicemail_password}, 0, 50));
          $post_add{description}                  = &database_clean_string(substr($form{description}, 0, 50));
          $post_add{domain_uuid}                  = $domain{uuid};
# Date :- 22-Feb-2021  Added by Atul for auto-generate-user and callcenter-agent 

          $post_add{create_user}                  = &database_clean_string(substr($form{create_user}, 0, 50));
          $post_add{create_call_center_agent}                  = &database_clean_string(substr($form{create_call_center_agent}, 0, 50));
          $post_add{agent_name}                  = &database_clean_string(substr($form{agent_name}, 0, 50));
          $post_add{agent_password}                  = &database_clean_string(substr($form{agent_password}, 0, 50));
          $post_add{extension_agent}                  = $extension;
          $post_add{username}                  = &database_clean_string(substr($form{username}, 0, 50));
          $post_add{password_user}                  = &database_clean_string(substr($form{password}, 0, 50));
          $post_add{confirmpassword}                  = &database_clean_string(substr($form{confirmpassword}, 0, 50));
          $post_add{user_email}                  = &database_clean_string(substr($form{user_email}, 0, 50));
          $post_add{contact_name_given}                  = &database_clean_string(substr($form{contact_name_given}, 0, 50));
          $post_add{contact_name_family}                  = &database_clean_string(substr($form{contact_name_family}, 0, 50));
          $post_add{group_name}                  = &database_clean_string(substr($form{group_name}, 0, 50));
          $post_add{agent_no_answer_delay_time}                  = &database_clean_string(substr($form{agent_no_answer_delay_time}, 0, 50));
          $post_add{agent_max_no_answer}                  = &database_clean_string(substr($form{agent_max_no_answer}, 0, 50));
          $post_add{agent_wrap_up_time}                  = &database_clean_string(substr($form{agent_wrap_up_time}, 0, 50));
          $post_add{agent_reject_delay_time}                  = &database_clean_string(substr($form{agent_reject_delay_time}, 0, 50));
          $post_add{agent_busy_delay_time}                  = &database_clean_string(substr($form{agent_busy_delay_time}, 0, 50));
        
        
        #outbound caller is checking if not set domain global did then must required outbound_caller_id_number when create extension
        if($post_add{outbound_caller_id_number} eq '')
        {
              $sql="SELECT 1, count(domain_setting_value) as tenant_outbound_caller_id_number  FROM v_domain_settings WHERE domain_uuid = '$domain{uuid}' AND domain_setting_subcategory = 'tenant_outbound_caller_id_number' AND domain_setting_enabled ='true'";
              %data = &database_select_as_hash($sql,"tenant_outbound_caller_id_number");
              $tenant_outbound_caller_id_number=$data{1}{tenant_outbound_caller_id_number};
              if($tenant_outbound_caller_id_number eq 0)
              {
                &print_api_error_end_exit(110, "outbound_caller_id_number required or set default domain based did");
              }
        }
        
        #This condition is validation required validation for create_user and create_call_center_agent 
        if(($post_add{create_user} eq '') || ($post_add{create_call_center_agent} eq ''))
        {
        &print_api_error_end_exit(110, "create_user and create_call_center_agent  required true/false");
        }
       
        # This condition is validating password and confirmpassword
        if ($post_add{password_user} ne $post_add{confirmpassword}) {
        &print_api_error_end_exit(110, "password/confirmpassword is not same");        
        }
        
        # this condition is check if create user false and callcenter agent true and added any agent name then name must be valid from the existing user because we have to display that name on the dropdown list in cc-agent page.
         if(($post_add{create_user} eq 'false') && ($post_add{agent_name} ne '') && ($post_add{create_call_center_agent} eq 'true'))
         {
             $sql="SELECT 1,count(username) as username from v_users where username='$post_add{agent_name}' and domain_uuid='$domain{uuid}'";
              %data = &database_select_as_hash($sql,"username");
              $check_agent_name=$data{1}{username};
              if($check_agent_name eq 0)
               {
                &print_api_error_end_exit(110, "Please enter valid username or create user set true");
               }
              
         }
         # this condition is checking if user is already exist in database or not
        if($post_add{create_user} eq 'true')
        {
                if(($post_add{username} eq '') ||($post_add{password_user} eq '') || ($post_add{confirmpassword} eq '') || ($post_add{user_email} eq '') ||($post_add{contact_name_given} eq '') ||($post_add{contact_name_family} eq '') ||($post_add{group_name} eq ''))
                {
                    &print_api_error_end_exit(110, "Required paramter is missing please check in the list if any one is missing:- username|password|confirmpassword|user_email|confirmpassword|group_name|contact_name_given");
                
                }
        
        
        
              $sql="SELECT 1,count(username) as username from v_users where username='$post_add{username}'and domain_uuid='$domain{uuid}' ";
              %data = &database_select_as_hash($sql,"username");
              $check_agent_name=$data{1}{username};
              
              if($check_agent_name eq 1)
              {
              $username=$post_add{username};
              &print_api_error_end_exit(110, "User $username  is already exists");
              }
        }
        
        # this condition is if create_user is true and create_call_center_agent is true then we are set the username as callcenter agent name 
        if(($post_add{create_user} eq 'true') && ($post_add{create_call_center_agent} eq 'true'))
        {
        $post_add{agent_name}=$post_add{username} ;
        }
        
        
        
         $sql="SELECT 1,group_uuid as group_uuid_name from v_groups where group_name='$post_add{group_name}'";
	 %data = &database_select_as_hash($sql,"group_uuid_name");
	 $group_uuid_name=$data{1}{group_uuid_name};
	 $post_add{group_uuid_name}=$group_uuid_name.'|'.$post_add{group_name};  
	 $post_add{apirequest}="true";  
          
        
          
#END      
          &post_data (
                     'domain_uuid' => $domain{uuid},
		     'urlpath'     => '/app/extensions/extension_edit.php',
		    # 'urlpath'     => '/app/extensions/test.php',
                     'reload'      => 0,
                     'data'        => [%post_add]);
          
          
          
          
          %hash = &database_select_as_hash("select 1,extension_uuid from v_extensions " .
                                           "where extension='$extension' and domain_uuid='$domain{uuid}'", 'uuid');
          if ($hash{1}{uuid}) {
               $response{stat}	= "ok";
               $response{data}{extension_uuid} = $hash{1}{uuid};
          } else {
               $response{stat}		= "fail";
               $response{message}	= "$extension\@$domain{name} not saved!";
          }
          
          
          ## response the user_uuid if user created successfully 
     
              $sql="SELECT 1,user_uuid as user_uuid from v_users where username='$post_add{username}'and domain_uuid='$domain{uuid}' ";
              %data = &database_select_as_hash($sql,"user_uuid");
              $user_uuid=$data{1}{user_uuid};
              if($user_uuid ne '')
              {
              $response{data}{user_uuid} = $user_uuid;
              }        
          ## response the callcenter_agent_uuid if Agent created successfully
              $sql="SELECT 1,call_center_agent_uuid as call_center_agent_uuid from v_call_center_agents where agent_name='$post_add{username}'and domain_uuid='$domain{uuid}' ";
              %data = &database_select_as_hash($sql,"call_center_agent_uuid");
              $call_center_agent_uuid=$data{1}{call_center_agent_uuid};
              if($call_center_agent_uuid ne '')
              {
              $response{data}{call_center_agent_uuid} = $call_center_agent_uuid;
              }        
          
        
     }
     
     &print_json_response(%response);    
}

sub editextension () {
     local $poststring_add = '
extension:10000
number_alias:admin
password:ML.6!TUH!Q
user_uuid:
voicemail_password:1234
accountcode:pbx.fusionpbx.cn
effective_caller_id_name:
effective_caller_id_number:
outbound_caller_id_name:
outbound_caller_id_number:
emergency_caller_id_name:
emergency_caller_id_number:
directory_full_name:
directory_visible:true
enabled_video_codec:false
directory_exten_visible:true
limit_max:5
limit_destination:
device_line_uuid:
line_number:
device_mac_address:
device_template:
voicemail_enabled:true
voicemail_mail_to:
voicemail_attach_file:true
voicemail_local_after_email:true
toll_allow:
call_timeout:30
call_group:
user_record:
hold_music:
user_context:pbx.fusionpbx.cn
auth_acl:
cidr:
sip_force_contact:
sip_force_expires:
force_ping:
nibble_account:
mwi_account:
sip_bypass_media:
dial_string:
enabled:true
description:
extension_uuid:bd24e793-2e1e-4352-9a29-8ddbb1880a89
domain_uuid:879b9f9b-e69d-4181-9d81-f6775341cc7d
delete_type:
delete_uuid:';
     
     local %post_add = ();
     for (split /\n/, $poststring_add) {
          ($key, $val) = split ':', $_, 2;
          next if !$key;
          $post_add{$key} = $val;
          $post_add{$key} = $form{$key} if defined $form{$key};
     }

     $response = ();
  
     %domain   = &get_domain();
     $uuid  = &clean_str(substr($form{extension_uuid},0,50),"MINIMAL","-_");
     
     if (!$domain{name}) {
          $response{stat}	= "fail";
          $response{message}= "$domain not exists!";
     }
      
     if ($response{stat} ne 'fail') {
          %hash = &database_select_as_hash(
                              "select
                                   1,extension_uuid
                              from
                                   v_extensions
                              where
                                   extension_uuid='$uuid' and
                                   domain_uuid='$domain{uuid}'",
                              'uuid');
          if (!$hash{1}{uuid}) {
               $response{stat}		= "fail";
               $response{message}	= "$extension not exists!";
          }
     }
    
     
     if ($response{stat} ne 'fail') {
          $enabled     = &get_enabled($form{enabled}) || 'true';
          $vm_enabled  = &get_enabled($form{vm_enabled}) || 'true';
          $voicemail_password = &clean_int($form{voicemail_password});
          $vm_mailto   = &database_clean_string(substr($form{vm_mailto}, 0, 50));          
          $user_record   = &database_clean_string(substr($form{user_record}, 0, 50));          
          $user_context = $domain{name};
          
          
          $post_add{enabled}   = $enabled;
          $post_add{vm_enabled}= $vm_enabled;
          $post_add{voicemail_password} = $voicemail_password;
          $post_add{vm_mailto}   = $vm_mailto;
          $post_add{user_context}= $user_context;
         
          if ($user_record eq 'all' || $user_record eq 'local' || $user_record eq 'inbound' || $user_record eq 'outbound') {
               $post_add{user_record} = $user_record;
          } else {
               $post_add{user_record} = '';              
          }
		  
          $post_add{user_uuid}                = &database_clean_string(substr $form{user_uuid}, 0, 100);
          $post_add{extension} = &database_clean_string(substr $form{extension}, 0, 20);
          $post_add{password}                = &database_clean_string(substr $form{password}, 0, 15);
          $post_add{accountcode}             = $form{accountcode} || $user_context;
          $post_add{autogen_users}           = &get_enabled($form{autogen_users}) || 'false';
          $post_add{directory_visible}       = &get_enabled($form{directory_visible}) || 'true';
          $post_add{directory_exten_visible} = &get_enabled($form{directory_exten_visible}) || 'true';
          $post_add{voicemail_attach_file}   = &get_enabled($form{voicemail_attach_file}) || 'true';
		  #Added by Hemant 21-07-2021
		  $post_add{enabled_video_codec} = &get_enabled($form{enabled_video_codec}) || 'false';
		  #End
		  ##Added By Hemant Chaudhari 17-11-2021
			$post_add{missed_call_app}     = &database_clean_string(substr($form{missed_call_app}, 0, 10));
			$post_add{missed_call_data}     = &database_clean_string(substr($form{missed_call_data}, 0, 50));
		  ##End
          $post_add{voicemail_local_after_email} = &get_enabled($form{voicemail_local_after_email}) || 'true';
          $post_add{call_timeout}                = &clean_int($form{call_timeout}) || 30;
          
          $post_add{effective_caller_id_name}    = &database_clean_string(substr($form{effective_caller_id_name}, 0, 50));
          $post_add{effective_caller_id_number}  = &database_clean_string(substr($form{effective_caller_id_number}, 0, 50));
          $post_add{outbound_caller_id_number}   = &database_clean_string(substr($form{outbound_caller_id_number}, 0, 50));
          $post_add{outbound_caller_id_name}     = &database_clean_string(substr($form{outbound_caller_id_name}, 0, 50));
          $post_add{directory_full_name}         = &database_clean_string(substr($form{directory_full_name}, 0, 50));
          $post_add{voicemail_password}          = &database_clean_string(substr($form{voicemail_password}, 0, 50));
          $post_add{description}                 = &database_clean_string(substr($form{description}, 0, 50));
         
          $post_add{extension_uuid} = $uuid;
	# Date :05-APR-2021 Added by Atul for fixing the API
	  $post_add{domain_uuid}=$domain{uuid};
         $post_add{apirequest}="true";

	# END          
		
          &post_data (
                     'domain_uuid' => $domain{uuid},
                     'urlpath'     => "/app/extensions/extension_edit.php?id=$uuid",
                     'reload'      => 0,
                     'data'        => [%post_add]);
        #Added by hemant Chaudhari 06-05-2021
		if ($response{stat} ne 'fail') {
          %hash = &database_select_as_hash(
                              "select
                                   1,extension_uuid
                              from
                                   v_extensions
                              where extension='$post_add{extension}' and extension_uuid != '$post_add{extension_uuid}' and 
                                   domain_uuid='$domain{uuid}'",
                              'uuid');
			if ($hash{1}) {
               $response{stat}		= "fail";
               $response{message}	= "Extension Already exists!";
			}else{
				$response{stat}	= "ok";
			}
		}
		#End
         
     }
     
     &print_json_response(%response);    
}

sub getextension () {

###dynamic_callerid:
     local $poststring_add = '
extension:10000
enabled_video_codec:
missed_call_app:
missed_call_data:
toll_allow:
absolute_codec_string:
force_ping:
number_alias:admin
password:ML.6!TUH!Q
accountcode:pbx.fusionpbx.cn
effective_caller_id_name:
effective_caller_id_number:
outbound_caller_id_name:
outbound_caller_id_number:
emergency_caller_id_name:
emergency_caller_id_number:
directory_first_name:
directory_visible:true
directory_exten_visible:true
limit_max:5
limit_destination:
call_timeout:30
call_group:
user_record:
hold_music:
user_context:pbx.fusionpbx.cn
auth_acl:
cidr:
sip_force_contact:
sip_force_expires:
nibble_account:
mwi_account:
sip_bypass_media:
dial_string:
enabled:true
description:
extension_uuid:bd24e793-2e1e-4352-9a29-8ddbb1880a89
domain_uuid:879b9f9b-e69d-4181-9d81-f6775341cc7d';
     
     local %post_add = ();
     for (split /\n/, $poststring_add) {
          ($key, $val) = split ':', $_, 2;
          next if !$key;
          $post_add{$key} = $val;
          $post_add{$key} = $form{$key} if defined $form{$key};
     }
     
     $fields = join ",", keys %post_add;
     $response = ();
    
     %domain= &get_domain();
     $uuid  = &clean_str(substr($form{extension_uuid},0,50),"MINIMAL","-_");
     
     if (!$domain{name}) {
          $response{stat}		= "fail";
          $response{message}	= "$domain not exists!";
     }
     
     $uuid   = &clean_str(substr($form{extension_uuid},0,50),"MINIMAL","-_");
     
     #warn "select 1,$fields from v_extensions where extension_uuid='$uuid' and domain_uuid='$domain{uuid}'";
     %hash = &database_select_as_hash ("select
                                             1,$fields
                                        from
                                             v_extensions
                                        where
                                             extension_uuid='$uuid' and
                                             domain_uuid='$domain{uuid}'",
                                        "$fields");
    
     
     if(!$hash{1}{extension_uuid}){
           
          $response{stat}	= "fail";
          $response{message}= &_("not found extension");;
     } else {
			
          $response{stat}     = "ok";
		  
		  %user_u = &database_select_as_hash ("select
												 user_uuid
											from
												 v_extension_users
											where
												 extension_uuid='$uuid' and
												 domain_uuid='$domain{uuid}'",
											"user_uuid");
			
			$i = 0;
			
			for (sort {$user_u{$a}{user_uuid} <=> $user_u{$b}{user_uuid}} keys %user_u) {
				push @options, {
								"user_list[$i][user_uuid]"  => $_
							   };
				$i++;				
			}
			
			%Device_list = &database_select_as_hash ("select
                            dev.device_template,dev.device_mac_address,dev_ln.device_line_uuid,dev_ln.line_number
                          from
                             v_devices dev, v_device_lines dev_ln
                          where
                             (dev_ln.user_id='$hash{1}{extension}' and dev_ln.domain_uuid='$domain{uuid}')and (dev.device_uuid=dev_ln.device_uuid)",
                          'val_1,device_line_uuid,val_2,device_template');
		  $l = 0;
		  
		  for (sort {$Device_list{$a}{val_1} <=> $Device_list{$b}{val_1}} keys %Device_list) {
			push @Device, {"device_provisioning[$l][line_number]"  => $Device_list{$_}{val_2},
						   "device_provisioning[$l][device_line_uuid]"  => $Device_list{$_}{device_line_uuid},
						   "device_provisioning[$l][device_mac_address]"  => $Device_list{$_}{val_1},
						   "device_provisioning[$l][device_template]"  => $_
					 };
			$l++;       
		  }
		
		    $response{data}{device_provisioning	} = \@Device;
			$response{data}{user_list} = \@options;
			
          %vm = &database_select_as_hash(
               "select
                    1,voicemail_enabled,voicemail_mail_to,voicemail_attach_file,voicemail_local_after_email,voicemail_password
               from
                    v_voicemails
               where
                   domain_uuid='$domain{uuid}' and
                   voicemail_id='$hash{1}{extension}'",
                   "voicemail_enabled,voicemail_mail_to,voicemail_attach_file,voicemail_local_after_email,voicemail_password");
          for (keys %post_add) {
               $response{data}{$_} = defined $hash{1}{$_} ? $hash{1}{$_} : '';
          }
		  
          $response{data}{voicemail_enabled} = $vm{1}{voicemail_enabled};
          $response{data}{voicemail_mail_to} = $vm{1}{voicemail_mail_to};
          $response{data}{voicemail_attach_file} = $vm{1}{voicemail_attach_file};
          $response{data}{voicemail_local_after_email} = $vm{1}{voicemail_local_after_email};
          $response{data}{voicemail_password} = $vm{1}{voicemail_password};
     }
     
     &print_json_response(%response);
}

### Date :01-04-2024 Added by Atul for develop extension_summary_api
sub extension_summary_report()
{
    local ($domain_name) = &database_clean_string($form{domain});
    my %domain = &get_domain();

    $include_internal => {type => 'string', maxlen => 50, notnull => 0, default => 'false'};
    $start_date = &database_clean_string(substr $form{start_date}, 0, 50);
    $end_date = &database_clean_string(substr $form{end_date}, 0, 50);
    $start_date = $start_date .' 00:00:00';
    $end_date = $end_date .' 23:59:59';
    $include_internal = $include_internal;

 
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain}/$form{domain_uuid} " . &_("does not exist"));
    }

if ($include_internal = 'true'){

local $fields = ' domain_uuid, domain_name, extension, number_alias, answered, missed, no_answer, busy, aloc, inbound_calls, inbound_duration, outbound_calls, outbound_duration, description';

	local $query = "SELECT e.domain_uuid, d.domain_name, e.extension, e.number_alias, COUNT(*) FILTER (WHERE c.extension_uuid = e.extension_uuid AND (answer_stamp IS NOT NULL AND bridge_uuid IS NOT NULL) AND (direction = 'inbound' OR direction = 'local')) AS answered, COUNT(*) FILTER (WHERE c.extension_uuid = e.extension_uuid AND missed_call = true AND (direction = 'inbound' OR direction ='local')) AS missed, COUNT(*) FILTER (WHERE c.extension_uuid = e.extension_uuid AND c.hangup_cause = 'NO_ANSWER' AND (direction = 'inbound' OR direction = 'local')) AS no_answer, COUNT(*) FILTER (WHERE c.extension_uuid = e.extension_uuid AND c.hangup_cause = 'USER_BUSY' AND (direction = 'inbound' OR direction = 'local')) AS busy,TO_CHAR(INTERVAL '1 second' * SUM(c.billsec) FILTER (WHERE c.extension_uuid = e.extension_uuid) / COUNT(*) FILTER (WHERE c.extension_uuid = e.extension_uuid), 'HH24:MI:SS') AS aloc, COUNT(*) FILTER (WHERE c.extension_uuid = e.extension_uuid AND (direction = 'inbound' OR direction = 'local')) AS inbound_calls, TO_CHAR (INTERVAL '1 second' * SUM(c.billsec) FILTER (WHERE c.extension_uuid = e.extension_uuid AND (direction = 'inbound' OR direction = 'local')), 'HH24:MI:SS') AS inbound_duration, COUNT(*) FILTER (WHERE c.extension_uuid = e.extension_uuid AND c.direction = 'outbound') AS outbound_calls, TO_CHAR (INTERVAL '1 second' * SUM(c.billsec) FILTER (WHERE c.extension_uuid = e.extension_uuid AND c.direction = 'outbound'), 'HH24:MI:SS') AS outbound_duration, e.description FROM v_extensions AS e, v_domains AS d, (SELECT domain_uuid, extension_uuid, caller_id_number, destination_number, missed_call, answer_stamp, bridge_uuid, direction, start_stamp, hangup_cause, originating_leg_uuid, billsec FROM v_xml_cdr WHERE domain_uuid = '$domain{uuid}' and start_stamp >= '$start_date' AND start_stamp <='$end_date') AS c  WHERE d.domain_uuid = e.domain_uuid AND e.domain_uuid = '$domain{uuid}' GROUP BY e.extension, e.domain_uuid, d.domain_uuid, e.number_alias, e.description ORDER BY extension ASC";

my @results;
        @results = &database_select($query, $fields);
        @results = grep { ref($_) eq 'HASH' } @results;

        for my $row (@results) {
                $response{data}{list} = \@results;
        }


}

else{

   local $fields = ' domain_uuid, domain_name, extension, number_alias, answered, missed, no_answer, busy, aloc, inbound_calls, inbound_duration, outbound_calls, outbound_duration, description';

 local $query = "select e.domain_uuid, d.domain_name, e.extension, e.number_alias, count(*) filter (where c.extension_uuid = e.extension_uuid and missed_call = false and (cc_side IS NULL or cc_side ='agent')and direction = 'inbound') as answered, count(*) filter (where c.extension_uuid = e.extension_uuid and missed_call = true and (cc_side is null or cc_side != 'agent')) as missed, count(*) filter (where c.extension_uuid = e.extension_uuid and c.hangup_cause = 'NO_ANSWER' and (cc_side IS NOT NULL or cc_side ='agent')and direction = 'inbound') as no_answer, count(*) filter (where c.extension_uuid = e.extension_uuid and c.hangup_cause = 'USER_BUSY' and direction = 'inbound') as busy, TO_CHAR(INTERVAL '1 second' * sum(c.billsec) filter ( where c.extension_uuid = e.extension_uuid and (direction = 'inbound' or direction = 'outbound')) / count(*) filter (where c.extension_uuid = e.extension_uuid and (direction = 'inbound' or direction = 'outbound')), 'HH24:MI:SS') as aloc, count(*) filter (where c.extension_uuid = e.extension_uuid and (cc_side is null or cc_side != 'agent') and direction = 'inbound') as inbound_calls, TO_CHAR(INTERVAL '1 second' * sum(c.billsec) filter ( WHERE c.extension_uuid = e.extension_uuid and direction = 'inbound'), 'HH24:MI:SS') as inbound_duration, count(*) filter (where c.extension_uuid = e.extension_uuid and c.direction = 'outbound') as outbound_calls, TO_CHAR(INTERVAL '1 second' * sum(c.billsec) filter ( WHERE c.extension_uuid = e.extension_uuid and c.direction = 'outbound'), 'HH24:MI:SS') as outbound_duration, e.description from v_extensions as e, v_domains as d, ( select domain_uuid, extension_uuid, caller_id_number, destination_number, missed_call, answer_stamp, bridge_uuid, direction, start_stamp, hangup_cause, originating_leg_uuid, billsec, cc_side, sip_hangup_disposition, voicemail_message from v_xml_cdr where domain_uuid = '$domain{uuid}' and start_stamp >= '$start_date' AND start_stamp <='$end_date') as c where d.domain_uuid = e.domain_uuid and e.domain_uuid = '$domain{uuid}' group by e.extension, e.domain_uuid, d.domain_uuid, e.number_alias, e.description order by extension asc";


my @results;
        @results = &database_select($query, $fields);
        @results = grep { ref($_) eq 'HASH' } @results;

        for my $row (@results) {
                $response{data}{list} = \@results;
        }

}
    $response{stat} = "Ok";

    &print_json_response(%response);

}

#### END 
sub getextensionlist () {
     local $poststring_add = '
extension_uuid:
extension:10000
password:ML.6!TUH!Q
user_context:pbx.fusionpbx.cn
enabled:true
description:
call_group:
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
     
     if (!$domain{name}) {
          $response{stat}		= "ok";
          $response{message}	= "$domain not exists!";
     }
     
     %hash = &database_select_as_hash_with_key (
                                             "select
                                                  extension_uuid,v_extensions.*
                                             from
                                                  v_extensions where domain_uuid='$domain{uuid}'",
                                             'extension_uuid',
                                             "$fields");
     
     $response{stat}	= "ok";
     $response{message}	= "OK";
     
     $response{data}{list} = [];
     for (sort {$hash{$a}{extension} cmp $hash{$b}{extension}} keys %hash) {
          push @{$response{data}{list}}, $hash{$_};
     }
     
     &print_json_response(%response);
}



sub deleteextension () {
     local $uuid  = &clean_str(substr($form{extension_uuid},0,50),"MINIMAL","-_");
     local $delete_user  = &clean_str(substr($form{delete_user},0,50),"MINIMAL","-_");
     
     warn $uuid;
     %domain   = &get_domain();
     $response = ();
     
    # Date :24-Feb-2021 Added by Atul For delete extension and callcenter user
     local %post_add = ();
     for (split /\n/, $poststring_add) {
          ($key, $val) = split ':', $_, 2;
          next if !$key;
          $post_add{$key} = $val;
     }
     $post_add{id} = $uuid;
# Date :24-Feb-2021 Added by Atul for delete user and contact
      if($delete_user eq '')
      {
        &print_api_error_end_exit(110, "delete_user is required fields so please enter true/false");
      }
      
		  %hash = &database_select_as_hash(
											 "select
												  1, extension_uuid
											 from
												  v_extensions
											 where
												  extension_uuid='$uuid'",
											 'uuid'
											);
		 if (!$hash{1}{uuid}) {
			&print_api_error_end_exit(110, "extension not Exist!");
		 }
	 
      if ($delete_user eq 'true')
        {
              $sql="SELECT 1,user_uuid as user_uuid from v_extension_settings where extension_uuid='$uuid'";
              %data = &database_select_as_hash($sql,"user_uuid");
              $user_uuid=$data{1}{user_uuid};
              if($user_uuid ne '')
              
              {
               $post_add{user_id} = $user_uuid;
               &post_data (
                    'domain_uuid' => $domain{uuid},
                    'reload'      => 0,
                    'urlpath' => '/app/extensions/user_delete.php?user_id=' . $user_uuid,
                    'data' => [%post_add]);
              }
        }
      
#End

	  $post_add{apirequest}="true"; 
            &post_data (
                    'domain_uuid' => $domain{uuid},
                    'reload'      => 0,
                    'urlpath' => '/app/extensions/extensions.php?id=' . $uuid,
                    'data' => [%post_add]
                );
     %hash     = &database_select_as_hash(
                                             "select
                                                  1, extension_uuid
                                             from
                                                  v_extensions
                                             where
                                                  extension_uuid='$uuid'",
                                             'uuid'
                                        );
                                                     
     if ($hash{1}{uuid}) {
          $response{stat}    = 'fail';
          $response{message} = 'Error';
     } else {
          $response{stat} = 'ok';
     }
     $response{data}{extension_uuid} = $uuid;
     
     &print_json_response(%response); 
}



sub setextensionforward () {
     local $poststring_add = '
forward_all_enabled:false
forward_all_destination:
follow_me_enabled:false
destination_data_1:8284665566
destination_delay_1:0
destination_timeout_1:15
destination_data_2:8384665566
destination_delay_2:5
destination_timeout_2:15
destination_data_3:
destination_delay_3:0
destination_timeout_3:30
destination_data_4:
destination_delay_4:0
destination_timeout_4:30
destination_data_5:
destination_delay_5:0
destination_timeout_5:30
cid_name_prefix:
call_prompt:true
dnd_enabled:false
submit:Save
';

     local %post_add = ();
     for (split /\n/, $poststring_add) {
          ($key, $val) = split ':', $_, 2;
          next if !$key;
          $post_add{$key} = $val;
     }
     

     local %params = (
          forward_all_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
          forward_all_destination => {type => 'string', maxlen => 20, notnull => 0, default => ''},
          follow_me_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
          
          destination_data_1 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
          destination_delay_1 => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
          destination_timeout_1 => {type => 'int', maxlen => 3, notnull => 1, default => '30'},
          
          destination_data_2 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
          destination_delay_2 => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
          destination_timeout_2 => {type => 'int', maxlen => 3, notnull => 1, default => '30'},
         
          destination_data_3 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
          destination_delay_3 => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
          destination_timeout_3 => {type => 'int', maxlen => 3, notnull => 1, default => '30'},
                  
          destination_data_4 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
          destination_delay_4 => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
          destination_timeout_4 => {type => 'int', maxlen => 3, notnull => 1, default => '30'},
          
          destination_data_5 => {type => 'string', maxlen => 20, notnull => 0, default => ''},
          destination_delay_5 => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
          destination_timeout_5 => {type => 'int', maxlen => 3, notnull => 1, default => '30'},
          
          cid_name_prefix => {type => 'string', maxlen => 255, notnull => 0, default => ''},
          call_prompt => {type => 'bool', maxlen => 10, notnull => 0, default =>'false'},
          dnd_enabled => {type => 'boll', maxlen => 10, notnull => 0, default => 'false'}        
    );
	 
	%response       = ();   
    %domain         = &get_domain();

     if (!$domain{name}) {
         $response{stat}	= "fail";
         $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
     }
     
     
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
     
     $uuid  = &clean_str(substr($form{extension_uuid},0,50),"MINIMAL","-_");

     %response  = ();
     if ($response{stat} ne 'fail') {
          %hash = &database_select_as_hash(
                         "select
                              1,extension_uuid
                         from
                              v_extensions
                         where
                              extension_uuid='$uuid' and
                              domain_uuid='$domain{uuid}'",
                         'uuid');
          if (!$hash{1}{uuid}) {
               $response{stat}		= "fail";
               $response{message}	= "$extension not exists!";
          }
     }
     
     if ($response{stat} ne 'fail') {
          for (keys %post_add) {
               $post_add{$_} ||= $form{$_};
          }

          &post_data (
                     'domain_uuid' => $domain{uuid},
                     'urlpath'     => "/app/calls/call_edit.php?id=$uuid",
                     'reload'      => 1,
                     'data'        => [%post_add]);          
         
          $response{stat}	    = "ok";
          $response{message}	= "OK";
     }
     &print_json_response(%response); 

}



return 1;

