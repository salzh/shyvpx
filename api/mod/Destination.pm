=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut


sub adddestination () {
   local $poststring_add = '
destination_type:inbound
destination_number:3109990000
destination_context:public
dialplan_details[0][dialplan_detail_type]:
dialplan_details[0][dialplan_detail_order]:10
dialplan_details[0][dialplan_detail_data]:transfer:100 XML shy.velantro.net
fax_uuid:06281b95-0896-4834-9039-cd7317134df3
destination_cid_name_prefix:
destination_accountcode:
destination_enabled:true
destination_description:to be deleted
';

   local %params = (
      destination_type => {type => 'enum:inbound,outbound', maxlen => 50, notnull => 1, default => ''},
      destination_number => {type => 'string', maxlen => 20, notnull => 1, default => ''},
      destination_context => {type => 'string', maxlen => 50, notnull => 0, default => 'public'},
	##Added By Hemant 23-11-2021
         ##destination_carrier_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
	  ####
      'dialplan_details[0][dialplan_detail_type]' => {type => 'string', maxlen => 20, notnull => 0, default => ''},
      'dialplan_details[0][dialplan_detail_order]' => {type => 'int', maxlen => 3, notnull => 0, default => '10'},
      'dialplan_details[0][dialplan_detail_data]' => {type => 'string', maxlen => 255, notnull => 1, default => ''},
      fax_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_cid_name_prefix => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_accountcode => {type => 'string', maxlen => 50, notnull => 0, default =>''},
      destination_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
      destination_description => {type => 'string', maxlen => 255, notnull => 0, default => ''},  
      # Date :19-Mar-2021  Added by Atul for Add destination :	
      destination_inbound_type  => {type => 'string', maxlen => 255, notnull => 0, default => 'general'}  
      #END  
   );
   
   local %post_add = ();
   for (split /\n/, $poststring_add) {
        ($key, $val) = split ':', $_, 2;
        next if !$key;
        $post_add{$key} = $val;
   }
   
   %response = ();
  
   %domain   = &get_domain();
   $response{stat} = 'ok';
   
   if (!$domain{name}) {
       $response{stat}		= "fail";
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
   

   if ($response{stat} ne 'fail') {
      %hash = &database_select_as_hash(
                    "select
                       1,destination_uuid
                    from
                       v_destinations
                    where
                       destination_number='$post_add{destination_number}'",
                    'uuid');
        
         if ($hash{1}{uuid}) {
            $response{stat}		= "fail";
            $response{message}	= &_("this destination already existed!");
         }
   }
   
#Date : 19-Mar-2021 ADDED BY ATUL FOR API FIXING
$post_add{db_destination_number}=$post_add{destination_number};
$post_add{domain_uuid}=$domain{uuid};
# END 
   if ($response{stat} ne 'fail') {
         &post_data (
            'domain_uuid' => $domain{uuid},
            'urlpath'     => '/app/destinations/destination_edit.php',
            'reload'      => 1,
            'data'        => [%post_add]);
        
         %hash = &database_select_as_hash(
                     "select
                       1,destination_uuid
                    from
                       v_destinations
                    where
                       destination_type='$post_add{destination_type}' and
                       destination_number='$post_add{destination_number}'",
                    'uuid');
         
         if ($hash{1}{uuid}) {
            $response{stat}		= "ok";
            $response{message}	= "OK";
            $response{data}{destination_uuid} = $hash{1}{uuid};
         } else {
            $response{stat}		= "fail";
            $response{message}	= &_("destination not saved!");
         }        
      }
     
   &print_json_response(%response);
}

sub editdestination () {
      local $poststring_add = '
destination_type:inbound
destination_number:3109990000
destination_context:public
dialplan_details[0][dialplan_detail_uuid]:69ba135a-0896-4834-9039-cd7317134df3
dialplan_details[0][dialplan_detail_type]:transfer
dialplan_details[0][dialplan_detail_order]:70
dialplan_details[0][dialplan_detail_data]:transfer:100 XML shy.velantro.net
fax_uuid:06281b95-0896-4834-9039-cd7317134df3
destination_cid_name_prefix:
destination_accountcode:
destination_enabled:true
destination_description:to be deleted
';

   local %params = (
      destination_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
      dialplan_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
      destination_type => {type => 'enum:inbound,outbound', maxlen => 50, notnull => 1, default => ''},
      destination_number => {type => 'string', maxlen => 20, notnull => 1, default => ''},
      db_destination_number => {type => 'string', maxlen => 20, notnull => 0, default => ''},
	  ##Added By Hemant 23-11-2021
	  ##destination_carrier_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
	  ####
      destination_context => {type => 'string', maxlen => 50, notnull => 0, default => 'public'},
      'dialplan_details[0][dialplan_detail_type]' => {type => 'string', maxlen => 20, notnull => 0, default => ''},
      'dialplan_details[0][dialplan_detail_order]' => {type => 'int', maxlen => 3, notnull => 0, default => '10'},
      'dialplan_details[0][dialplan_detail_data]' => {type => 'string', maxlen => 255, notnull => 1, default => ''},
      fax_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_cid_name_prefix => {type => 'string', maxlen => 50, notnull => 0, default => ''},
      destination_accountcode => {type => 'string', maxlen => 50, notnull => 0, default =>'false'},
      destination_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
      destination_description => {type => 'string', maxlen => 255, notnull => 0, default => ''},     
	  # Date :19-Mar-2021  Added by Hemant for Add destination :
      destination_inbound_type  => {type => 'string', maxlen => 255, notnull => 0, default => 'general'}  
      #END
   );
   
   local %post_add = ();
   for (split /\n/, $poststring_add) {
        ($key, $val) = split ':', $_, 2;
        next if !$key;
        $post_add{$key} = $val;
   }
   
   for (0..9) {
      last unless $form{"dialplan_details[" . $_ . "][dialplan_detail_data]"};
      $post_add{"dialplan_details[" . $_ . "][dialplan_detail_type]"} =
            &database_clean_string($form{"dialplan_details[" . $_ . "][dialplan_detail_type]"});
      
      $post_add{"dialplan_details[" . $_ . "][dialplan_detail_data]"} =
            &database_clean_string($form{"dialplan_details[" . $_ . "][dialplan_detail_data]"});
	  $post_add{"dialplan_details[" . $_ . "][dialplan_detail_order]"} =
            &database_clean_string($form{"dialplan_details[" . $_ . "][dialplan_detail_order]"});
	  $post_add{"dialplan_details[" . $_ . "][dialplan_detail_uuid]"} =
            &database_clean_string($form{"dialplan_details[" . $_ . "][dialplan_detail_uuid]"});
      
   }
   
   %response = ();
  
   %domain   = &get_domain();
   $response{stat} = 'ok';
   
   if (!$domain{name}) {
       $response{stat}		= "fail";
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
   
   if ($response{stat} ne 'fail') {
      %hash = &database_select_as_hash(
                    "select
                       1,destination_uuid
                    from
                       v_destinations
                    where
                       destination_number='$post_add{destination_number}' and
					   destination_uuid != '$post_add{destination_uuid}'",
                    'uuid');
        
         if ($hash{1}{uuid}) {
            $response{stat}		= "fail";
            $response{message}	= &_("this destination already existed!");
         }
		 
		 %hash_1 = &database_select_as_hash(
                    "select
                       1,destination_uuid
                    from
                       v_destinations
                    where
                       domain_uuid = '$domain{uuid}' and
					   destination_uuid = '$post_add{destination_uuid}'",
                    'uuid');
        
         if (!$hash_1{1}{uuid}) {
            $response{stat}		= "fail";
            $response{message}	= &_("Destination uuid not Exist!");
         }
		 
		 %hash_2 = &database_select_as_hash(
                    "select
                       1,dialplan_uuid
                    from
                       v_dialplans
                    where
                       domain_uuid='$domain{uuid}' and
					   dialplan_uuid = '$post_add{dialplan_uuid}'",
                    'uuid');
        
         if (!$hash_2{1}{uuid}) {
            $response{stat}		= "fail";
            $response{message}	= &_("Dialplan uuid not Exist!");
         }
   }
   
#Date : 19-Mar-2021 ADDED BY ATUL FOR API FIXING
#$post_add{db_destination_number}=$post_add{destination_number};
$post_add{domain_uuid}=$domain{uuid};
# END 

   if ($response{stat} ne 'fail') {
         &post_data (
            'domain_uuid' => $domain{uuid},
            'urlpath'     => "/app/destinations/destination_edit.php?id=$post_add{destination_uuid}",
            'reload'      => 1,
            'data'        => [%post_add]);
        
		warn "edit destination: " . Dumper(\%post_add);
         %hash = &database_select_as_hash(
                     "select
                       1,destination_uuid
                    from
                       v_destinations
                    where
                       destination_type='$post_add{destination_type}' and
                       destination_number='$post_add{destination_number}'",
                    'uuid');
         
         if ($hash{1}{uuid}) {
            $response{stat}		= "ok";
            $response{message}	= "OK";
            $response{data}{destination_uuid} = $hash{1}{uuid};
         } else {
            $response{stat}		= "fail";
            $response{message}	= &_("destination not saved!");
         }        
      }
     
   &print_json_response(%response);
}

sub deletedestination () {
   $uuid    = $form{destination_uuid};
   %response=();
   $response{stat}		= "ok";
   
	%hash = &database_select_as_hash(
				 "select
				   1,destination_uuid
				from
				   v_destinations
				where
				   destination_uuid='$uuid'",
				'uuid');
	 
	 if (!$hash{1}{uuid}) {
		$response{stat}		= "fail";
		$response{message}	= &_("destination UUID Not Exist!");
	 }       
	 
   if (!$uuid) {
      $response{stat}		= "fail";
      $response{message}	= &_("destination_uuid is null!");   
   } 
		 
   if ($response{stat} ne 'fail') {
      %domain   = &get_domain();

      if (!$domain{name}) {
         $response{stat}		= "1";
         $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
      }   
   }
   

# Date 19-Mar-2021 Added by Atul for pass array as argument 
$post_add{"id[0]"} = $uuid;
$data=%post_add;
# end 


   if ($response{stat} ne 'fail') {   
      &post_data (
         'domain_uuid' => $domain{uuid},
         #'urlpath'     => '/app/destinations/destination_delete.php' . "?id=$uuid",
	 'urlpath'     => '/app/destinations/destination_delete.php',
	 'reload'      => 0,
         'data'        => [%post_add]);
    
      $response{stat}	= "ok";
      $response{message}= "OK";
     # $response{data}{destination_uuid} = $hash{1}{uuid};
       $response{data}{destination_uuid} = $uuid;
   }
   
   &print_json_response(%response);   

}

sub getdestinationlist () {
   
   local %params = (
      destination_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
      destination_type => {type => 'enum:inbound,outbound', maxlen => 50, notnull => 1, default => ''},
      destination_number => {type => 'string', maxlen => 20, notnull => 1, default => ''},
      destination_context => {type => 'string', maxlen => 50, notnull => 0, default => 'public'},
      destination_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
	  dialplan_uuid => {type => 'bool', maxlen => 10, notnull => 0, default => ''},
	  ##Added By Hemant 23-11-2021##
	  ##destination_carrier_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
	  ##End
      destination_description => {type => 'string', maxlen => 255, notnull => 0, default => ''}      
   );
   
   @fields = keys %params;
   
   $response = ();
   $response{stat}   = "ok";
  
   %domain           = &get_domain();

   if (!$domain{name}) {
       $response{stat}		= "fail";
       $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
   }
   
   if ($response{stat} ne 'fail') {
         
         $field_string = join ",", @fields;
         %hash = &database_select_as_hash_with_auto_key(
                     "select
                        $field_string
                     from
                        v_destinations
                     where
                        domain_uuid='$domain{uuid}'",
                     $field_string
                     
                  );
         
         $list = [];
         for (sort {$hash{$a}{destination} cmp $hash{$b}{destination}} keys %hash) {
			 
			  push @$list, $hash{$_};
			  
			if ($hash{$_}{dialplan_uuid}) {
				$hash{$_}{destination_status} = "Assigned"
			}else{
				$hash{$_}{destination_status} = "Available"
			}
			
         }
         
         $response{stat}		= "ok";
         $response{message}		= "OK";
         $response{data}{destination_list}	= $list;
   }
   
   &print_json_response(%response);
}

##### Date :04-04-2024 Added by Atul for destination summary report
sub destination_summary_report()
{
    local ($domain_name) = &database_clean_string($form{domain});
    my %domain = &get_domain();

    $start_date = &database_clean_string(substr $form{start_date}, 0, 50);
    $end_date = &database_clean_string(substr $form{end_date}, 0, 50);
    $start_date=$start_date .' 00:00:00';
    $end_date = $end_date .' 23:59:59';
    
	if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain}/$form{domain_uuid} " . &_("does not exist"));
    }


    my $fields = ' domain_uuid, domain_name, destination_uuid, dialplan_uuid, destination_type, destination_prefix, destination_number, total_calls, answered_calls, unique_callers, total_seconds, destination_description';

    my %hash = &database_select_as_hash(
        "SELECT $fields FROM v_destinations WHERE domain_uuid='$domain{uuid}'",
        $fields
    );

     my $query = "select d.domain_uuid, n.domain_name, d.destination_uuid, d.dialplan_uuid, d.destination_type, d.destination_prefix, d.destination_number, count(*) filter (where caller_destination in (d.destination_number, concat(d.destination_prefix, d.destination_number),  concat('+', d.destination_prefix, d.destination_number)) and (cc_side is null or cc_side <> 'agent')) as total_calls, count(*) filter (where caller_destination in (d.destination_number, concat(d.destination_prefix, d.destination_number),  concat('+', d.destination_prefix, d.destination_number)) and billsec > 0) as answered_calls, count(distinct(c.caller_id_number)) filter ( where caller_destination in (d.destination_number, concat(d.destination_prefix, d.destination_number),  concat('+', d.destination_prefix, d.destination_number)) and billsec > 0 ) as unique_callers, TO_CHAR(INTERVAL '1 SECOND' * sum(billsec) filter (WHERE caller_destination in (d.destination_number, concat(d.destination_prefix, d.destination_number),  concat('+', d.destination_prefix, d.destination_number)) and billsec > 0 ), 'HH24:MI:SS') as duration, d.destination_description from v_destinations as d, v_domains as n, ( select domain_uuid, extension_uuid, caller_id_name, caller_id_number, caller_destination, destination_number, missed_call, answer_stamp, bridge_uuid, direction, start_stamp, hangup_cause, originating_leg_uuid, billsec, cc_side, sip_hangup_disposition from v_xml_cdr where domain_uuid = '$domain{uuid}' and direction = 'inbound' and caller_destination is not null AND start_stamp >= '$start_date' AND start_stamp <='$end_date') as c where d.domain_uuid = n.domain_uuid and d.domain_uuid = '$domain{uuid}' and destination_type = 'inbound' and destination_enabled = 'true' group by d.domain_uuid, d.destination_uuid, d.dialplan_uuid, n.domain_name, d.destination_type, d.destination_prefix, d.destination_number order by destination_number asc";

	my @results;
	@results = &database_select($query, $fields);
	@results = grep { ref($_) eq 'HASH' } @results; 

	for my $row (@results) 
	{
        	$response{data}{list} = \@results;
	} 
 
    &print_json_response(%response);

}

####### END 

sub getdestination () {
   local $uuid = &database_clean_string(substr $form{destination_uuid}, 0, 50);
   $response = ();
   $response{stat}   = "ok";
  
   if (!$uuid) {
      $response{stat}		= "fail";
      $response{message}	= &_("destination_uuid is null!");   
   }
   
   if ($response{stat} ne 'fail') {
   
      local %params = (
         destination_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
		 ##Added By Hemant Chaudhari 23-11-2021
		 ###destination_carrier_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		 destination_inbound_type => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		 destination_cid_name_prefix => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		 domain_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		 fax_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		 destination_accountcode => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		 ####End
         destination_type => {type => 'enum:inbound,outbound', maxlen => 50, notnull => 1, default => ''},
         destination_number => {type => 'string', maxlen => 20, notnull => 1, default => ''},
         destination_context => {type => 'string', maxlen => 50, notnull => 0, default => 'public'},
         destination_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
         destination_description => {type => 'string', maxlen => 255, notnull => 0, default => ''},      
         dialplan_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''}      
      );
      
      @fields = keys %params;
      
     
      %domain           = &get_domain();
   
      
      if (!$domain{name}) {
          $response{stat}		= "fail";
          $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
      }
      
      if ($response{stat} ne 'fail') {
            
            $field_string = join ",", @fields;
            %hash = &database_select_as_hash(
                        "select
                           1,$field_string
                        from
                           v_destinations
                        where
                           domain_uuid='$domain{uuid}' AND
                           destination_uuid='$uuid'",
                        $field_string
                        
            );

            if ($hash{1}{destination_uuid}) {
               $response{stat}		= "ok";
               $response{message}	= "OK";
               $response{data} = $hash{1};
			   $response{data}{db_destination_number} = $hash{1}{destination_number};
			   
				@actions = ();
				
               if ($hash{1}{dialplan_uuid}) {
                  %d = &database_select_as_hash(
                        "select
                           dialplan_detail_uuid, dialplan_detail_type,dialplan_detail_data,dialplan_detail_order
                        from
                           v_dialplan_details
                        where
                           dialplan_uuid='$hash{1}{dialplan_uuid}' and dialplan_detail_type !='destination_number' and dialplan_detail_type !='set'",
                        "type,data,order");
                  $i = 0;
					for (sort {$d{$a}{order} <=> $d{$b}{order}} keys %d) {
						push @actions, {"actions[$i][dialplan_detail_type]" => $d{$_}{type},
										"actions[$i][dialplan_detail_data]" => $d{$_}{data},
										"actions[$i][dialplan_detail_order]" => $d{$_}{order},
										"actions[$i][dialplan_detail_uuid]" => $_
						};
						$i++;                
					}
				  
               }
			   $hash{1}{actions} = \@actions;
            } else {
               $response{stat}		= "fail";
               $response{message}	= &_('not found');
            }
      }
   }   
   &print_json_response(%response);
}

sub make_available_did {
   $uuid    = $form{dialplan_uuid};
   %response=();
   $response{stat}		= "ok";

   if (!$uuid) {
      $response{stat}		= "fail";
      $response{message}	= &_("dialplan_uuid is null!");   
   }
   
   if ($response{stat} ne 'fail') {
      %domain   = &get_domain();

      if (!$domain{name}) {
         $response{stat}	= "fail";
         $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
      }   
   }
   
   if ($response{stat} ne 'fail') {   
      &post_data (
         'domain_uuid' => $domain{uuid},
         'urlpath'     => '/app/dialplan/dialplan_delete_make_available.php' . "?id[]=$uuid&app_uuid=c03b422e-13a8-bd1b-e42b-b6b9b4d27ce4",
         'reload'      => 1,
         'data'        => []);
    
      $response{stat}	= "ok";
      $response{message}= "OK";
      $response{data}{dialplan_uuid} = $uuid;

   }
   
   &print_json_response(%response);   
}

return 1;
