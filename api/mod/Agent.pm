=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

sub addagent () {
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    
    local %params = (
        agent_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        agent_status => {type => 'string', maxlen => 50, notnull => 0, default => 'Available'},
        agent_contact => {type => 'string', maxlen => 250, notnull => 1, default => ''},        
        agent_type => {type => 'string', maxlen => 20, notnull => 0, default => 'callback'},
        agent_call_timeout => {type => 'int', maxlen => 5, notnull => 0, default =>'10'},
        agent_no_answer_delay_time => {type => 'int', maxlen => 5, notnull => 0, default => '10'},
        agent_max_no_answer => {type => 'int', maxlen => 5, notnull => 0, default => '0'},
        agent_wrap_up_time => {type => 'int', maxlen => 5, notnull => 0, default => '10'},
        agent_reject_delay_time => {type => 'int', maxlen => 5, notnull => 0, default => '10'},
        agent_busy_delay_time => {type => 'int', maxlen => 5, notnull => 0, default => '60'},
        agent_logout => {type => 'string', maxlen => 250, notnull => 0, default => ''},
		# Date :19-10-2022 Added by Hemant for Add Presence Out
		presence_out => {type => 'string', maxlen => 50, notnull => 0, default => 'false'},
		# Date :23-APR-2021 Added by Atul for Add Agent id and Agent password
        agent_id => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        agent_password => {type => 'string', maxlen => 250, notnull => 0, default => ''},
    );
	 

    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    
	for $k (keys %params) {
        $tmpval   = '';
        if (&getvalue(\$tmpval, $k, $params{$k})) {
            $post_add{$k} = $tmpval;
        } else {
            $response{stat}	= "fail";
            $response{message}	= $k. &_(" not valid");
        }
    }
    

    
    if ($response{stat} ne 'fail') {
        %hash = &database_select_as_hash(
                "select
                    1,call_center_agent_uuid
                from
                    v_call_center_agents
                where
                    domain_uuid='$domain{uuid}' and
                    agent_name='$post_add{agent_name}'",
                'uuid'
        );
        
        if ($hash{1}{uuid}) {
             &print_api_error_end_exit(120, "$post_add{agent_name} already added!");
        }
	        
	$post_add{apirequest}="true";
        &post_data (
                     'domain_uuid' => $domain{uuid},
                     'urlpath'     => '/app/call_centers/call_center_agent_edit.php',
                     'data'        => [%post_add]);
          
        %hash = &database_select_as_hash(
              "select
                  1,call_center_agent_uuid
              from
                  v_call_center_agents
              where
                  domain_uuid='$domain{uuid}' and
                  agent_name='$post_add{agent_name}'",
              'uuid'
        );
        
        if ($hash{1}{uuid}) {
            $response{stat}                         = 'ok';
            $response{data}{call_center_agent_uuid} = $hash{1}{uuid};
        } else {
            $response{stat}    = 'fail';
            $response{message} = 'not saved'
        }
    }
    
    
    &print_json_response(%response);       
}

sub editagent() {
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    
    local %params = (
        call_center_agent_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        agent_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        agent_status => {type => 'string', maxlen => 50, notnull => 0, default => 'Available'},
        agent_contact => {type => 'string', maxlen => 250, notnull => 1, default => ''},        
        agent_type => {type => 'string', maxlen => 20, notnull => 0, default => 'callback'},
        agent_call_timeout => {type => 'int', maxlen => 5, notnull => 0, default =>'10'},
        agent_no_answer_delay_time => {type => 'int', maxlen => 5, notnull => 0, default => '10'},
        agent_max_no_answer => {type => 'int', maxlen => 5, notnull => 0, default => '10'},
        agent_wrap_up_time => {type => 'int', maxlen => 5, notnull => 0, default => '10'},
        agent_reject_delay_time => {type => 'int', maxlen => 5, notnull => 0, default => '10'},
        agent_busy_delay_time => {type => 'int', maxlen => 5, notnull => 0, default => '60'},
        agent_logout => {type => 'string', maxlen => 250, notnull => 0, default => ''},
		# Date :19-10-2022 Added by Hemant for Add Presence Out
		presence_out => {type => 'string', maxlen => 50, notnull => 0, default => 'false'},
		# Date :23-APR-2021 Added by Atul for update Agent id and Agent password
        agent_id => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        agent_password => {type => 'string', maxlen => 250, notnull => 0, default => ''},
    );
	 

    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    
	for $k (keys %params) {
		 $tmpval   = '';
		 if (&getvalue(\$tmpval, $k, $params{$k})) {
			 $post_add{$k} = $tmpval;
		 } else {
			 $response{stat}	= "fail";
			 $response{message}	= $k. &_(" not valid");
		 }
	 }
    

    
    if ($response{stat} ne 'fail') {
        %hash = &database_select_as_hash(
                "select
                    1,call_center_agent_uuid
                from
                    v_call_center_agents
                where
                    domain_uuid='$domain{uuid}' and
                    agent_name='$post_add{agent_name}' and
                    call_center_agent_uuid <> '$post_add{call_center_agent_uuid}'",
                'uuid'
        );
        
        if ($hash{1}{uuid}) {
             &print_api_error_end_exit(120, "$post_add{agent_name} already added!");
        }
       
	 
	$post_add{apirequest}="true";
        &post_data (
                     'domain_uuid' => $domain{uuid},
                     'urlpath'     => "/app/call_centers/call_center_agent_edit.php?id=$post_add{call_center_agent_uuid}",
                     'data'        => [%post_add]);
          
        %hash = &database_select_as_hash(
              "select
                  1,call_center_agent_uuid
              from
                  v_call_center_agents
              where
                  domain_uuid='$domain{uuid}' and
                  agent_name='$post_add{agent_name}'",
              'uuid'
        );
        
        if ($hash{1}{uuid}) {
            $response{stat}                         = 'ok';
            $response{data}{call_center_agent_uuid} = $hash{1}{uuid};
        } else {
            $response{stat}    = 'fail';
            $response{message} = 'not saved'
        }
    }
    
    
    &print_json_response(%response);    
}

sub getagentlist () {
    local %response       = ();   
    local %domain         = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $fields = 'call_center_agent_uuid,agent_id,agent_name,agent_type,agent_call_timeout,agent_contact,agent_status,agent_max_no_answer';
    %hash = &database_select_as_hash(
                "select
                    call_center_agent_uuid,$fields
                from
                     v_call_center_agents
                where
                    domain_uuid='$domain{uuid}'",
                $fields
    );
    
    $output = &runswitchcommand('internal', 'callcenter_config agent list');
    %agent_status = ();
    for (split /\n/, $output) {
    	@cols = split /\|/;
    	$agent_status{$cols[0]} = $cols[5];
    	warn $cols[0], ' ==> ', $cols[5], "\n";
    }
    for (sort {$hash{$a}{agent_name} cmp $hash{$b}{agent_name}} keys %hash) {
    		##$hash{$_}{agent_status} = $agent_status{$hash{$_}{agent_name} . '@' . $domain{name}};
    		##$hash{$_}{agent_status} = $agent_status{$hash{$_}{agent_name} . '@' . $domain{name}};
        push @{$response{data}{list}}, $hash{$_};
    }
    
    $response{stat} = 'ok';
    
    &print_json_response(%response);    
}

sub getagent() {
    local %response       = ();   
    local %domain         = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $call_center_agent_uuid = &database_clean_string(substr $form{call_center_agent_uuid}, 0, 50);
    $fields = 'call_center_agent_uuid,agent_id,agent_password,agent_name,agent_type,agent_call_timeout,agent_contact,agent_status,agent_max_no_answer,' .
              'agent_logout,agent_wrap_up_time,presence_out,agent_reject_delay_time,agent_busy_delay_time,agent_no_answer_delay_time';
    %hash = &database_select_as_hash(
                "select
                    1,$fields
                from
                     v_call_center_agents
                where
                    domain_uuid='$domain{uuid}' and
                    call_center_agent_uuid='$call_center_agent_uuid'",
                $fields
    );
    


    if ($hash{1}) {    
        $response{stat} = 'ok';
        $response{data} = $hash{1};
    } else {
        $response{stat}    = 'fail';
        $response{message} = "Agent not found";
    }
    
    &print_json_response(%response);     
}
##### Date :05-04-2024 Added by Atul for get agent break report
sub getagent_pause_type() {
    local %response       = ();
    local %domain         = &get_domain();

    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }

 $fields = 'agent_break_type_uuid,domain_uuid,agent_break_type,agent_break_description';
    %hash = &database_select_as_hash(
                "select agent_break_type_uuid,
                    $fields
                from
                     v_agent_break_types
                where
                    domain_uuid='$domain{uuid}'",
                $fields
    );

	  $response{data}{list} = [];

	 for (sort {$hash{$a}{agent_break_type} cmp $hash{$b}{agnet_break_type}} keys %hash) {
          push  @{$response{data}{list}}, $hash{$_};
     }


        $response{stat}    = 'ok';

    &print_json_response(%response);
}
#############END

######Date : 05-04-2024 Added by Atul get Add agentbreak type
sub add_agentpause_type()
{
     use Data::UUID;
     $ug    = Data::UUID->new;
     $uuid = $ug->create_str();
      
     %response = ();
     %domain = &get_domain();
   
        local ($agent_break_type) = &database_clean_string(substr $form{agent_pause_type}, 0, 50);
        local $agent_break_description = &database_clean_string(substr $form{agent_pause_description}, 0, 50);

      if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
       }

        local $sql = "SELECT 1,agent_break_type from v_agent_break_types where domain_uuid='$domain{uuid}' and agent_break_type='$agent_break_type' limit 1";
        local %data = &database_select_as_hash($sql, "agent_break_type");	       
		
	$user_punch_id=$data{1}{agent_break_type};
        $response{stat2} = "$user_punch_id";
		if($user_punch_id){
             		&print_api_error_end_exit(120, "already added!");
            	}
        	elsif (!$agent_break_type) {
        		$response{status} = "You have not entered Agent_break_type";
        		&print_json_response(%response);
        		return;  # Exit the subroutine early since no further processing is needed
    		} 
		
		else {
        		&database_do("INSERT INTO v_agent_break_types (agent_break_type_uuid, domain_uuid, agent_break_type, agent_break_description) VALUES ('$uuid', '$domain{uuid}', '$agent_break_type', '$agent_break_description')");
    		}

    $response{stat1} = "$agent_break_type";
    $response{stat} = "ok";
    $response{data}{agent_break_type_uuid} = $uuid;
    &print_json_response(%response);

}

######Date : 10-04-2024 Added by Atul edit agentbreak type
sub edit_agentpause_type()
{
    local %post_add = ();
    %response       = ();
    %domain         = &get_domain();
	 local $agent_break_type = &database_clean_string(substr $form{agent_pause_type}, 0, 50);
	 local $agent_break_type_uuid = &database_clean_string(substr $form{agent_pause_type_uuid}, 0, 50);
   	 local $agent_break_description = &database_clean_string(substr $form{agent_pause_description}, 0, 50);
	 use DBI;
         $dbh = DBI->connect($app{database_dsn}, $app{database_user}, $app{database_password});
         use DBD::Pg qw(:pg_types);
	
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }

    if ((!$agent_break_type && !$agent_break_description)){
	
    	$response{pause_code} = "Empty value..!";
	} 
    
    else{

        $sth = $dbh->prepare("UPDATE v_agent_break_types SET agent_break_type = '$agent_break_type', agent_break_description = '$agent_break_description' WHERE agent_break_type_uuid = '$agent_break_type_uuid'");
	$sth->execute();
    	$response{pause_code} = "Pause code Updated successfully";
	}
	
    	$response{stat} = "Ok";


        
    &print_json_response(%response);
}

#############END

######Date : 10-04-2024 Added by Atul delete agentbreak type
sub delete_agentpause_type()
{

    %domain         = &get_domain();
    local $agent_break_type_uuid = &database_clean_string(substr $form{agent_pause_type_uuid}, 0, 50);
    	
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
   use DBI;
   $dbh = DBI->connect($app{database_dsn}, $app{database_user}, $app{database_password});
   use DBD::Pg qw(:pg_types);
	$sth = $dbh->prepare("DELETE FROM v_agent_break_types WHERE agent_break_type_uuid = '$agent_break_type_uuid' and domain_uuid='$domain{uuid}'");
    $sth->execute();
    $response{stat1} = $agent_break_type_uuid;
    $response{stat} = "Ok";
    &print_json_response(%response);
} 

############END #############
##### Date :11-04-2024 Added by Atul for get agent_pause_summary
sub agent_pause_summary_report()
{
    local ($domain_name) = &database_clean_string($form{domain});
    my %domain = &get_domain();

    $insert_date = &database_clean_string(substr $form{insert_date}, 0, 50);
    $agent_name = &database_clean_string(substr $form{agent_name}, 0, 50);


    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain}/$form{domain_uuid} " . &_("does not exist"));
    }
   
   if(!$agent_name){

   $fields = ' Agent Name, Break Type, Break Start Time, Break End Time, Total Break Time';

   $query="select vca.agent_name AS agent_name, vcapt.agent_punch_status AS break_type, vcapt.punch_in As break_start_time, vcapt.punch_out AS break_end_time, (vcapt.punch_out - vcapt.punch_in) AS total_break_time
from v_call_center_agents_punch_times AS vcapt inner join v_call_center_agents AS vca on vcapt.call_center_agent_uuid = vca.call_center_agent_uuid
where vcapt.agent_punch_status NOT IN ('Available','Available (On Demand)','Logged Out') and vcapt.domain_uuid = '$domain{uuid}' and vcapt.insert_date >= '${insert_date}'";

}

  else{ 
   $fields = ' Agent Name, Break Type, Break Start Time, Break End Time, Total Break Time';

   $query="select vca.agent_name AS agent_name, vcapt.agent_punch_status AS break_type, vcapt.punch_in As break_start_time, vcapt.punch_out AS break_end_time, (vcapt.punch_out - vcapt.punch_in) AS total_break_time 
from v_call_center_agents_punch_times AS vcapt inner join v_call_center_agents AS vca on vcapt.call_center_agent_uuid = vca.call_center_agent_uuid 
where agent_name = '$agent_name' and vcapt.agent_punch_status NOT IN ('Available','Available (On Demand)','Logged Out') and vcapt.domain_uuid = '$domain{uuid}' and vcapt.insert_date >= '${insert_date}'";
 }
	
my @results;
        @results = &database_select($query, $fields);
        @results = grep { ref($_) eq 'HASH' } @results;
        
        for my $row (@results) {
        $response{data}{list} = \@results;
	}

    $response{agent_name} = "$agent_name";
    $response{stat} = "Ok";
    &print_json_response(%response);
}
##### END ###
#### Date : 05-04-2024 Added by Atul for get agent_summary_report
sub agent_summary_report()
{
    
    local ($domain_name) = &database_clean_string($form{domain});
    my %domain = &get_domain();

    $include_internal => {type => 'string', maxlen => 50, notnull => 0, default => 'false'};
    $start_date = &database_clean_string(substr $form{start_date}, 0, 50);
    $end_date = &database_clean_string(substr $form{end_date}, 0, 50);
    $start_date = $start_date .' 00:00:00';
    $end_date = $end_date .' 23:59:59';

    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain}/$form{domain_uuid} " . &_("does not exist"));
    }

     local $fields = ' domain_uuid, domain_name, agent_name, answered, missed, call_time, wait_time, avg_wait_time';


     $query = "select a.domain_uuid, d.domain_name, a.agent_name, count(*) filter ( where c.cc_agent::UUID = a.call_center_agent_uuid and missed_call = false and cc_cause = 'answered' and (cc_side IS NOT NULL or cc_side ='agent')) as answered, count(*) filter ( where c.cc_agent::UUID =  a.call_center_agent_uuid  and c.hangup_cause = 'NO_ANSWER'  and (cc_side IS NOT NULL or cc_side ='agent') ) as missed, TO_CHAR(INTERVAL '1 second' * SUM(c.billsec) FILTER (WHERE c.cc_agent::UUID = a.call_center_agent_uuid and (cc_side IS NOT NULL or cc_side ='agent')), 'HH24:MI:SS') AS call_time, TO_CHAR(INTERVAL '1 second' * SUM(c.waitsec) FILTER (WHERE c.cc_agent::UUID = a.call_center_agent_uuid and (cc_side IS NOT NULL or cc_side ='agent')), 'HH24:MI:SS') AS wait_time, TO_CHAR(INTERVAL '1 second' * AVG(c.waitsec) FILTER (WHERE c.cc_agent::UUID = a.call_center_agent_uuid and (cc_side IS NOT NULL or cc_side ='agent')), 'HH24:MI:SS') AS avg_wait_time from v_call_center_agents as a, v_domains as d, (select domain_uuid, cc_agent, cc_side, cc_cause, missed_call, start_stamp, hangup_cause, waitsec, billsec from v_xml_cdr where domain_uuid = '$domain{uuid}' and start_stamp >= '$start_date' AND start_stamp <='$end_date') as c where d.domain_uuid = a.domain_uuid and a.domain_uuid = '$domain{uuid}' group by a.agent_name, a.domain_uuid, d.domain_uuid order by agent_name asc";


my @results;
        @results = &database_select($query, $fields);
        @results = grep { ref($_) eq 'HASH' } @results;
        
        for my $row (@results) {
        $response{data}{list} = \@results;
        }

    $response{stat} = "Ok";
    &print_json_response(%response);


}

###########END 
sub deleteagent () {
    $call_center_agent_uuid = &database_clean_string(substr $form{call_center_agent_uuid}, 0, 100);
	 
    %domain         = &get_domain();
    
	#DATE :26-MAR-2021 ADDED BY ATUL FOR FIXING THE DELETE AGENT RELATED ISSUES
	$post_add{id}=$call_center_agent_uuid;

	#END 
	
		%hash = &database_select_as_hash(
						"select
							1,call_center_agent_uuid
						from
							v_call_center_agents
						where
							domain_uuid='$domain{uuid}' and 
							call_center_agent_uuid='$post_add{id}'",
						'uuid');
		
		if($call_center_agent_uuid){
			
			$post_add{apirequest}="true";
			&post_data (
				 'domain_uuid' => $domain{uuid},
				 'urlpath'     => "/app/call_centers/call_center_agents.php?id=$post_add{id}",
				 'reload'      => 0,
				 'data'        => [%post_add]);    
				 
			$response{stat} = 'ok';
			$response{uuid} = $post_add{id};
			
		} 
			
		
    
    &print_json_response(%response);
}

return 1;
