=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

sub addcallcenter() {
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    
    local %params = (
        queue_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        queue_extension => {type => 'string', maxlen => 20, notnull => 1, default => ''},
        queue_strategy => {type => 'enum:ring-all,round-robin-w-memory,longest-idle-agent,round-robin,top-down,agent-with-least-talk-time,agent-with-fewest-calls,sequentially-by-agent-order,sequentially-by-next-agent-order,random', maxlen => 50, notnull => 0, default => 'ring-all'},
        queue_moh_sound => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_record_template => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_time_base_score => {type => 'string', maxlen => 50, notnull => 0, default => 'system'},
        queue_max_wait_time => {type => 'int', maxlen => 5, notnull => 0, default =>'0'},
        queue_max_wait_time_with_no_agent => {type => 'int', maxlen => 5, notnull => 0, default => '30'},        
        queue_max_wait_time_with_no_agent_time_reached => {type => 'int', maxlen => 5, notnull => 0, default => '60'},
        queue_timeout_action => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_tier_rules_apply => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_tier_rule_wait_second => {type => 'int', maxlen => 5, notnull => 0, default => '3'},
        queue_tier_rule_wait_multiply_level => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        queue_tier_rule_no_agent_no_wait => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_discard_abandoned_after => {type => 'int', maxlen => 5, notnull => 0, default => '60'},
        queue_abandoned_resume_allowed => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_cid_prefix => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        queue_announce_sound => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_announce_frequency => {type => 'string', maxlen => 250, notnull => 0, default => '0'},
        queue_description => {type => 'string', maxlen => 250, notnull => 0, default => ''},
		missed_call_email => {type => 'string', maxlen => 250, notnull => 0, default => ''},
		#Added By Hemant Chaudhari 04-05-2021
		agent_name => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        tier_level => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
        tier_position => {type => 'int', maxlen => 3, notnull => 0, default => '1'}
		#End
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
    
# Date :-11-Mar-2021 Added By Atul for notification add in Queue

if ($post_add{missed_call_email} ne '')
{
$post_add{queue_missed_call_data}=$post_add{missed_call_email};
$post_add{queue_missed_call_app}='email';
}

# Date :-29-8-2023  Added by Atul for agent uuid

	$post_add{agent_name} =~ s/\%20/ /g;
local $sql = "SELECT 1,call_center_agent_uuid from v_call_center_agents where domain_uuid='$domain{uuid}' and agent_name='$post_add{agent_name}' limit 1";
        local %data = &database_select_as_hash($sql, "call_center_agent_uuid");

        $user=$data{1}{call_center_agent_uuid};
		$post_add{agent_uuid}=$user;


$post_add{apirequest}="true";
#END

    #Code Added By Hemant Chaudhari
    %queue_ext = &database_select_as_hash(
                "select
                    1,queue_extension
                from
                    v_call_center_queues
                where
                    queue_extension='$post_add{queue_extension}' or queue_name='$post_add{queue_name}' and
					domain_uuid='$domain{uuid}'",
                'uuid'
        );
				
	
		
	if ($queue_ext{1}){
		$response{stat}		= "fail";
		$response{message}	= "Call Center Already Exists. Please add Extension and Call Center name must be unique";
		
	} else {
		
		if ($response{stat} ne 'fail') {     
		   %result = &post_data (
						 'domain_uuid' => $domain{uuid},
				 'urlpath'     => '/app/call_centers/call_center_queue_edit.php',
			   #  'urlpath'     => '/app/call_centers/debug.php',
				 'data'        => [%post_add]);
			  
			  $location = $result->header("Location");

			  ($uuid) = $location =~ /id=(.+)$/;
			  if (!$uuid) {
				   $response{stat}		= "fail";
				   $response{message}	= "Data not saved";
			  } else {         
				   $response{stat}                         = "ok";
				   $response{data}{call_center_queue_uuid} = $uuid;
			  }
		}
		
    }
	#End
    &print_json_response(%response);    
}

sub editcallcenter () {
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    
    local %params = (
        call_center_queue_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},        
        queue_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        queue_extension => {type => 'string', maxlen => 20, notnull => 1, default => ''},
        queue_strategy => {type => 'enum:ring-all,round-robin-w-memory,longest-idle-agent,round-robin,top-down,agent-with-least-talk-time,agent-with-fewest-calls,sequentially-by-agent-order,sequentially-by-next-agent-order,random', maxlen => 50, notnull => 0, default => 'ring-all'},
        queue_moh_sound => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_record_template => {type => 'string', maxlen => 10, notnull => 0, default => ''},
        queue_time_base_score => {type => 'string', maxlen => 50, notnull => 0, default => 'system'},
        queue_max_wait_time => {type => 'int', maxlen => 5, notnull => 0, default =>'0'},
        queue_max_wait_time_with_no_agent => {type => 'int', maxlen => 5, notnull => 0, default => '30'},        
        queue_max_wait_time_with_no_agent_time_reached => {type => 'int', maxlen => 5, notnull => 0, default => '60'},
        queue_timeout_action => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_tier_rules_apply => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_tier_rule_wait_second => {type => 'int', maxlen => 5, notnull => 0, default => '3'},
        queue_tier_rule_wait_multiply_level => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        queue_tier_rule_no_agent_no_wait => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_discard_abandoned_after => {type => 'int', maxlen => 5, notnull => 0, default => '60'},
        queue_abandoned_resume_allowed => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_cid_prefix => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        queue_announce_sound => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_announce_frequency => {type => 'string', maxlen => 250, notnull => 0, default => '0'},
        queue_description => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        agent_name => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        tier_level => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
		call_center_tier_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        tier_position => {type => 'int', maxlen => 3, notnull => 0, default => '1'},
		# Date :11-Mar-2021 Added By Atul For add email in callcenter 
		missed_call_email => {type => 'string', maxlen => 250, notnull => 0, default => ''}
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
    
# Date :-11-Mar-2021 Added By Atul for notification add in Queue

if ($post_add{missed_call_email} ne '')
{
$post_add{queue_missed_call_data}=$post_add{missed_call_email};
$post_add{queue_missed_call_app}='email';
}

	$post_add{agent_name} =~ s/\%20/ /g;
local $sql = "SELECT 1,call_center_agent_uuid from v_call_center_agents where domain_uuid='$domain{uuid}' and agent_name='$post_add{agent_name}' limit 1";
        local %data = &database_select_as_hash($sql, "call_center_agent_uuid");

        $user=$data{1}{call_center_agent_uuid};
warn $sql;
$post_add{apirequest}="true";
$post_add{agent_uuid}=$user;
#END 

#Code Added By Hemant Chaudhari
    %queue_ext_edt = &database_select_as_hash(
                "select
                    1,queue_extension
                from
                    v_call_center_queues
                where
                    call_center_queue_uuid != '$post_add{call_center_queue_uuid}' and (queue_extension='$post_add{queue_extension}' or queue_name='$post_add{queue_name}') and 
					domain_uuid='$domain{uuid}'",
                'uuid'
        );    
    
	if ($queue_ext_edt{1}){
		$response{stat}		= "fail";
		$response{stat1}		= $user;
		$response{message}	= "Call Center Already Exists. Please add Esxtension and Call Center name must be unique";
		
	} else {
	
		if ($response{stat} ne 'fail') {
			$post_add{id} = $post_add{call_center_queue_uuid};
			if ($form{call_center_tier_uuid}) {
				$post_add{delete_type} = 'tier';
				$post_add{delete_uuid} = $form{call_center_tier_uuid}
			}
			
			%hash = &database_select_as_hash(
					"select
						1,call_center_queue_uuid
					from
						v_call_center_queues
					where
						domain_uuid='$domain{uuid}' and
						call_center_queue_uuid='$post_add{call_center_queue_uuid}'",
					'uuid'
			);
		
			if ($hash{1}) {
				$post_add{id} = $post_add{call_center_queue_uuid};
				%result = &post_data (
							'domain_uuid' => $domain{uuid},
							'urlpath'     => "/app/call_centers/call_center_queue_edit.php?id=$post_add{call_center_queue_uuid}",
							'data'        => [%post_add]);
				  
					$location = $result->header("Location");
					($uuid) = $location =~ /id=(.+)$/;
					if (!$uuid) {
						$response{stat}		= "fail";
						$response{message}	= "Error";
					} else {         
						$response{stat}                         = "ok";
						$response{data}{call_center_queue_uuid} = $uuid;
					}
			} else {
				$response{stat}		= "fail";
				$response{message}	= "Call CENTER QUEUE NOT FOUND";
			}
		}
    }
	
    &print_json_response(%response);    
}

sub getcallcenterlist () {
    local %response       = ();   
    local %domain         = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $fields = 'call_center_queue_uuid,queue_name,queue_extension,queue_strategy,queue_tier_rules_apply,queue_description';
    %hash = &database_select_as_hash(
                "select
                    call_center_queue_uuid,$fields
                from
                    v_call_center_queues
                where
                    domain_uuid='$domain{uuid}'",
                $fields
    );
    
    for (sort {$hash{$a}{queue_name} cmp $hash{$b}{queue_name}} keys %hash) {
        push @{$response{data}{list}}, $hash{$_};
    }
    
    $response{stat} = 'ok';
    
    &print_json_response(%response);
}

sub getcallcenter () {
    local %response       = ();   
    local %domain         = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $call_center_queue_uuid = &database_clean_string(substr $form{call_center_queue_uuid}, 0, 50);
    
     local %params = (
        call_center_queue_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},        
        queue_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        queue_extension => {type => 'string', maxlen => 20, notnull => 1, default => ''},
        queue_strategy => {type => 'enum:ring-all,longest-idle-agent,round-robin,top-down,agent-with-least-talk-time,agent-with-fewest-calls,sequentially-by-agent-order,sequentially-by-next-agent-order,random', maxlen => 50, notnull => 0, default => 'ring-all'},
        queue_moh_sound => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_record_template => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_time_base_score => {type => 'string', maxlen => 50, notnull => 0, default => 'system'},
        queue_max_wait_time => {type => 'int', maxlen => 5, notnull => 0, default =>'0'},
        queue_max_wait_time_with_no_agent => {type => 'int', maxlen => 5, notnull => 0, default => '30'},        
        queue_max_wait_time_with_no_agent_time_reached => {type => 'int', maxlen => 5, notnull => 0, default => '60'},
        queue_timeout_action => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_tier_rules_apply => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_tier_rule_wait_second => {type => 'int', maxlen => 5, notnull => 0, default => '3'},
        queue_tier_rule_wait_multiply_level => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        queue_tier_rule_no_agent_no_wait => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_discard_abandoned_after => {type => 'int', maxlen => 5, notnull => 0, default => '60'},
        queue_abandoned_resume_allowed => {type => 'bool', maxlen => 10, notnull => 0, default => 'false'},
        queue_cid_prefix => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        queue_announce_sound => {type => 'string', maxlen => 250, notnull => 0, default => ''},
        queue_announce_frequency => {type => 'string', maxlen => 250, notnull => 0, default => '0'},
        queue_description => {type => 'string', maxlen => 250, notnull => 1, default => ''},
        
        agent_name => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        tier_level => {type => 'int', maxlen => 3, notnull => 0, default => '0'},
        tier_postion => {type => 'int', maxlen => 3, notnull => 0, default => '1'},
        
        delete_type => {type => 'string', maxlen => 50, notnull => 0, default => 'tier'}
    );
    $fields = 'call_center_queue_uuid,queue_name,queue_extension,queue_strategy,queue_tier_rules_apply,queue_description,' .
              'queue_moh_sound,queue_record_template,queue_time_base_score,queue_max_wait_time,' .
              'queue_max_wait_time_with_no_agent,queue_max_wait_time_with_no_agent_time_reached,' .
              'queue_timeout_action,queue_tier_rules_apply,queue_tier_rule_wait_second,queue_tier_rule_wait_multiply_level,' .
              'queue_tier_rule_no_agent_no_wait,queue_discard_abandoned_after,queue_abandoned_resume_allowed,' .
              'queue_cid_prefix,queue_announce_sound,queue_announce_frequency';
              
              
    %hash = &database_select_as_hash(
                "select
                    1,$fields
                from
                    v_call_center_queues
                where
                    domain_uuid='$domain{uuid}' and
                    call_center_queue_uuid='$call_center_queue_uuid'",
                $fields
    );
    
    if ($hash{1}) {
        $response{stat} = 'ok';
        $response{data} = $hash{1};
        
        %tier = &database_select_as_hash(
            "select
                call_center_tier_uuid,call_center_tier_uuid,agent_name,tier_level,tier_position
            from
                v_call_center_tiers
            where
                domain_uuid='$domain{uuid}' and
                queue_name='$hash{1}{queue_name}'",
            "call_center_tier_uuid,agent_name,tier_level,tier_position"
        );
        
# Date :12-Mar-2021 Added by Atul for Agent list in callcenter 

 $list  = [];
  for (sort {$tier{$a}{call_center_tier_uuid} cmp $tier{$b}{call_center_tier_uuid}} keys %tier) {
	push @{$response{data}{tier_list}}, $tier{$_};
	}
#END
	
        
    } else {
        $response{stat}    = 'fail';
        $response{message} = "not found call_center";
    }
    
    &print_json_response(%response);   
}

sub deletecallcenter () {
    local %response       = ();   
    local %domain         = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $call_center_queue_uuid = &database_clean_string(substr $form{call_center_queue_uuid}, 0, 50);

	$post_add{id}=$call_center_queue_uuid;    

    %hash = &database_select_as_hash(
                "select
                    1,call_center_queue_uuid
                from
                    v_call_center_queues
                where
                    domain_uuid='$domain{uuid}' and
                    call_center_queue_uuid='$call_center_queue_uuid'",
                'uuid'
    );
    
    if ($hash{1}{uuid}) {
       
	$post_add{apirequest}="true";
        &post_data (
             'domain_uuid' => $domain{uuid},
             'urlpath'     => "/app/call_centers/call_center_queues.php?id=$post_add{id}",
             'reload'      => 0,
             'data'        => [%post_add]);
	$response{stat} = 'ok';    
    } else {
        $response{stat}    = 'fail';
        $response{message} = "not found call_center"
    }
    
    &print_json_response(%response);
}

####Date :08-Mar-2021 
####Added by : Atul Akabari 
####Purpose : For the deletecallcenter Agent:
sub deletecallcenteragent()
{
local ($domain_name) = &database_clean_string($form{domain});
%domain         = &get_domain();
if (!$domain{name}) {
 	&print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
}
$delete_uuid = &database_clean_string(substr $form{call_center_tier_uuid}, 0, 50);
if($delete_uuid)
{

        &post_data (
            'domain_uuid' => $domain{uuid},
             'urlpath'     => '/app/call_centers/call_center_queue_edit.php' . "?call_center_tier_uuid=$delete_uuid&a=delete",
             'reload'      => 0,
             'data'        => []); 
	$response{stat} = 'ok';
	$response{call_center_tier_uuid} = $delete_uuid;
	
}
      
	&print_json_response(%response);   
}

################################################
# Date :11-03-2024 Added by Atul for get callcenter summary report 
##############################################

sub get_callcenter_summary_report()
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

    #my $fields = ' queue_name, total_calls, answered_calls, answered_percentage, total_call_time, total_wait_time, average_wait_time, tta_30_percentage, abandoned_calls , missed_calls, thirty_TTA_number';    
    
     my $fields = ' queue_name, total_calls, answered_calls, answered_percentage, missed_calls, abandoned_calls, thirty_TTA_number, tta_30_percentage, total_call_time, total_wait_time, average_wait_time';    

    my %hash = &database_select_as_hash(
        "SELECT $fields FROM v_call_center_queues WHERE domain_uuid='$domain{uuid}'",
        $fields
    );

    my $query = "SELECT
   ccq.queue_name,ccq.queue_name,
   subquery.total_calls,
   subquery.answered_calls,
   CASE
       WHEN subquery.total_calls > 0 THEN ROUND((subquery.answered_calls * 100.0) / subquery.total_calls, 2)
       ELSE 0
   END AS answered_percentage,
   subquery.missed_calls,
   subquery.abandoned_calls,
   subquery.thirty_TTA_number,
   ROUND(CASE
             WHEN subquery.answered_calls > 0 THEN CAST((subquery.thirty_TTA_number * 100.0) / subquery.answered_calls AS numeric)
             ELSE 0
         END, 2) AS TTA_30_percentage,
   TO_CHAR((subquery.total_call_duration + subquery.total_wait_duration) * INTERVAL '1 second', 'HH24:MI:SS') AS total_call_time,
   TO_CHAR(INTERVAL '1 second' * subquery.total_wait_duration, 'HH24:MI:SS') AS total_wait_time,
   CASE
       WHEN subquery.answered_calls > 0 THEN TO_CHAR(INTERVAL '1 second' * ROUND(subquery.total_wait_duration / subquery.answered_calls), 'HH24:MI:SS')
       ELSE '00:00:00' 
   END AS average_wait_time
FROM (
        SELECT
            call_center_queue_uuid,
            COUNT(*) AS total_calls,
            SUM(CASE WHEN cc_cause = 'answered' THEN 1 ELSE 0 END) AS answered_calls,
            SUM(CASE WHEN cc_cause = 'answered' AND waitsec <= 30 THEN 1 ELSE 0 END) AS thirty_TTA_number,
            SUM(CASE WHEN waitsec <= 30 THEN 1 ELSE 0 END) AS TTA_30,
            SUM(CASE WHEN cc_cancel_reason = 'TIMEOUT' AND cc_cause = 'cancel' THEN 1 ELSE 0 END) as missed_calls,
            SUM(CASE WHEN cc_cause = 'cancel' and cc_cancel_reason = 'BREAK_OUT' THEN 1 ELSE 0 END) AS abandoned_calls,
            SUM(CASE
                    WHEN cc_side = 'member'
                    THEN EXTRACT(EPOCH FROM ((end_epoch || ' seconds')::interval - (cc_queue_answered_epoch || ' seconds')::interval))
                    ELSE 0
                END) AS total_call_duration,
            SUM(waitsec) AS total_wait_duration
        FROM v_xml_cdr
        WHERE domain_uuid = '$domain{uuid}'
          AND cc_side = 'member'
          AND start_stamp >= '$start_date' AND start_stamp <='$end_date'
        GROUP BY call_center_queue_uuid
    ) AS subquery
JOIN v_call_center_queues ccq ON subquery.call_center_queue_uuid = ccq.call_center_queue_uuid";

    %hash = &database_select_as_hash($query, $fields);

        for my $key (sort { $hash{$a}{queue_name} cmp $hash{$b}{queue_name} } keys %hash) {
        push @{$response{data}{list}}, $hash{$key};
        }

    $response{stat} = "Ok";
   # $response{sta1t} = $query;

    &print_json_response(%response);
}

            


#sub get_callcenter_summary_report()
#{
#local ($domain_name) = &database_clean_string($form{domain});
#%domain         = &get_domain();
#if (!$domain{name}) {
# 	&print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
#}

#$fields = 'call_center_queue_uuid,queue_name,queue_extension,queue_strategy,queue_tier_rules_apply,queue_description';
#$fields = 'queue_name,call_center_queue_uuid,total_calls,answered_calls,answered_percentage,total_call_time,total_wait_time,average_wait_time,tta_30_percentage,abandoned_calls';
    
					

#    for (sort {$hash{$a}{queue_name} cmp $hash{$b}{queue_name}} keys %hash) {
#        push @{$response{data}{list}}, $hash{$_};
#    }	
#	$response{stat}="Ok"; 
#	&print_json_response(%response);   
#}
 
############################


############END ##############

#### Date :-11-Mar-2021 
#### Developed By : Atul Akabari 
#### Purpose : Added Agent into the callenter 
sub addagent_into_callcenter()
{
$queue_name = &database_clean_string(substr $form{queue_name}, 0, 50);
$agent_name = &database_clean_string(substr $form{agent_name}, 0, 50);
$tier_level = &database_clean_string(substr $form{tier_level}, 0, 50);
$tier_position = &database_clean_string(substr $form{tier_position}, 0, 50);
local ($domain_name) = &database_clean_string($form{domain});
%domain         = &get_domain();
if (!$domain{name}) {
 	&print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
}


$response{stat}="Ok"; 
&print_json_response(%response); 
}


sub deletecallcenteragent_old () {
    local %response       = ();   
    local %domain         = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    $delete_uuid = &database_clean_string(substr $form{call_center_tier_uuid}, 0, 50);
    %tier = &database_select_as_hash(
        "select
            1,call_center_tier_uuid
        from
            v_call_center_tiers
        where
            call_center_tier_uuid='$delete_uuid'",
        "uuid");
    
    if (!$tier{1}{uuid}) {
        $response{stat}    = 'fail';
        $response{message} = "not found this tier";
        &print_json_response(%response);

    } else {
        &editcallcenter();
    }        
}

return 1;
