=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

sub adduser () {
    local $poststring_add = '
username:zhong
password:123
confirmpassword:123
user_email:zhongxiang721@gmail.com
contact_name_given:zhong
contact_name_family:weixiang
contact_organization:zhong
submit:Create Account
';

    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    
    local %params = (
        username => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        password => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        confirmpassword => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        #password_confirm => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        user_email => {type => 'string', maxlen => 255, notnull => 1, default => ''},
        group_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        contact_name_given => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        contact_name_family => {type => 'string', maxlen => 50, notnull => 0, default =>''},
        contact_organization => {type => 'string', maxlen => 50, notnull => 0, default => ''},        
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
   
    if ($post_add{password} ne $post_add{confirmpassword}) {
    #if ($post_add{password} ne $post_add{password_confirm}) {
        &print_api_error_end_exit(110, "password/confirmpassword is not same");        
    }
    
    if ($response{stat} ne 'fail') {
        %hash = &database_select_as_hash("select
                                    1,user_uuid
                                from
                                    v_users
                                where
                                    username='$post_add{username}' and
                                    domain_uuid='$domain{uuid}'",
                                'uuid');
        if ($hash{1}{uuid}) {
            $response{stat}    = 'fail';
            $response{message} = "$post_add{username} already existed";
        }
    }
   
 #### Added by Atul for get group uuid 
	 

	$sql="SELECT 1,group_uuid as group_uuid_name from v_groups where group_name='$post_add{group_name}'";
	%data = &database_select_as_hash($sql,"group_uuid_name");
	$group_uuid_name=$data{1}{group_uuid_name};
	$post_add{group_uuid_name}=$group_uuid_name.'|'.$post_add{group_name};
	$post_add{domain_uuid}=$domain{uuid};
	$post_add{password_confirm}=$post_add{confirmpassword};
	$post_add{password_confirm}=$post_add{confirmpassword};
	$post_add{apirequest}="true";

 #######END


    if ($response{stat} ne 'fail') { 
        &post_data (
                'domain_uuid' => $domain{uuid},
                #'urlpath'     => '/core/users/signup.php',
                'urlpath'     => '/core/users/user_edit.php',
                # 'urlpath'     => '/core/users/test.php',
                'reload'      => 0,
                'data'        => [%post_add]);
        
        %hash = &database_select_as_hash("select
                                            1,user_uuid
                                        from
                                            v_users
                                        where
                                            username='$post_add{username}' and
                                            domain_uuid='$domain{uuid}'",
                                        'uuid');
		#warn $result->content;
        if ($hash{1}{uuid}) {
           $response{stat}	= "ok";
           $response{data}{user_uuid} = $hash{1}{uuid};
        } else {
           $response{stat}		= "fail";
           $response{message}	= "$post_add{username} not saved!";
        }
        
    }
   
    
   &print_json_response(%response);
}

sub edituser () {
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();

    local %params = (
        user_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        username => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        password => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        confirmpassword => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        group_name => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        contact_uuid  => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        user_status => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        user_language => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        user_time_zone => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        user_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
	user_email => {type => 'string', maxlen => 255, notnull => 1, default => ''},
        username_old => {type => 'string', maxlen => 50, notnull => 1, default => ''},
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
	
        %hash = &database_select_as_hash("select
                                    1,user_uuid
                                from
                                    v_users
                                where
                                    user_uuid='$post_add{user_uuid}' and
                                    domain_uuid='$domain{uuid}'",
                                'uuid');
        if (!$hash{1}{uuid}) {
            $response{stat}    = 'fail';
            $response{message} = "user_uuid not exist";
        }       
	
    $post_add{id} = $post_add{user_uuid};
    
    if ($post_add{password} ne $post_add{confirmpassword}) {
        &print_api_error_end_exit(110, "password/confirmpassword is not same");        
    }
    if ($post_add{username} ne $post_add{username_old}) {
        %hash = &database_select_as_hash("select
                                    1,user_uuid
                                from
                                    v_users
                                where
                                    username='$post_add{username}' and
                                    domain_uuid='$domain{uuid}'",
                                'uuid');
        if ($hash{1}{uuid}) {
            $response{stat}    = 'fail';
            $response{message} = "$post_add{username} already existed";
        }       
    }
	
	#Added By Hemant Chaudhari 29-10-2021
	if ($post_add{user_uuid} ne $post_add{group_name}) {
		%hash = &database_select_as_hash("select
                                    1,group_name
                                from
                                    v_group_users
                                where
                                    user_uuid='$post_add{user_uuid}' and group_name='$post_add{group_name}' and 
                                    domain_uuid='$domain{uuid}'",
                                'group');
		if ($hash{1}{group} eq $post_add{group_name}) {
			$post_add{group_name} = '';
		}    
	}
	#End
	
	# Date :- 19-Mar-2021 Added by Atul for get user group uuid
	$sql="SELECT 1,group_uuid as group_uuid_name from v_groups where group_name='$post_add{group_name}'";
	%data = &database_select_as_hash($sql,"group_uuid_name");
	$group_uuid_name=$data{1}{group_uuid_name};
	#$post_add{group_uuid_name}=$group_uuid_name;
	$post_add{group_uuid_name}=$group_uuid_name.'|'.$post_add{group_name};
	$post_add{domain_uuid}=$domain{uuid};
	$post_add{password_confirm}=$post_add{confirmpassword};
	
	$post_add{apirequest}="true";
	# end    
	
    if ($response{stat} ne 'fail') {    
        &post_data (
                'domain_uuid' => $domain{uuid},
                #'urlpath'     => "/core/users/usersupdate.php?id=$post_add{user_uuid}",
                'urlpath'     => "/core/users/user_edit.php?id=$post_add{user_uuid}",
                'reload'      => 0,
                'data'        => [%post_add]);
        
        %hash = &database_select_as_hash("select
                                            1,user_uuid
                                        from
                                            v_users
                                        where
                                            username='$post_add{username}' and
                                            domain_uuid='$domain{uuid}'",
                                        'uuid');
		#warn $result->content;
        if ($hash{1}{uuid}) {
           $response{stat}		      = "ok";
           $response{data}{user_uuid} = $hash{1}{uuid};
        } else {
           $response{stat}		= "fail";
           $response{message}	= "$post_add{username} not saved!";
        }
        
    }
   
   &print_json_response(%response);
}

sub getuserlist () {
    local %response       = ();   
    local %domain         = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    %hash = &database_select_as_hash("select
                                        v_users.user_uuid,v_users.user_uuid,username,user_enabled,group_name
                                    from
                                        v_users left join v_user_groups
                                    on
                                        v_users.user_uuid=v_user_groups.user_uuid
                                    where
                                        v_users.domain_uuid='$domain{uuid}'",
                                    "user_uuid,username,user_enabled,group_name");
    
    for (sort {$hash{$a}{username} cmp $hash{$b}{username}} keys %hash) {
        push @{$response{data}{list}}, $hash{$_};
    }
    
    $response{stat} = 'ok';
    &print_json_response(%response);
}

sub getuser () {
    local %response       = ();   
    local %domain         = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    local $user_uuid = &database_clean_string(substr $form{user_uuid}, 0, 50);
    
    $fields = "username,user_enabled,contact_uuid,user_status";
    %hash = &database_select_as_hash("select
                                        1,v_users.user_uuid,$fields
                                    from
                                        v_users left join v_user_groups
                                    on
                                        v_users.user_uuid=v_user_groups.user_uuid
                                    where
                                        v_users.domain_uuid='$domain{uuid}' and
                                        v_users.user_uuid='$user_uuid'",
                                    "user_uuid,$fields");
    if (!$hash{1}{user_uuid}) {
        $response{stat}		= "fail";
        $response{message}	= "usr not found";       
    } else {
        $response{data} = $hash{1};
        %settings = &database_select_as_hash(
                        "select
                            user_setting_uuid,user_setting_subcategory,user_setting_value
                        from
                            v_user_settings
                        where
                            user_uuid='$user_uuid' and
                            user_setting_enabled='true'",
                        "category,value");
        for (sort keys %settings) {
            $response{data}{"user_" . $settings{$_}{category}} = $settings{$_}{value};
        }
    }
    
	@options = ();
		%o = &database_select_as_hash(
					"select
						group_name,user_group_uuid,group_uuid
					from
						v_user_groups where domain_uuid='$domain{uuid}' and user_uuid = '$user_uuid'",
					'group_name,user_group_uuid,group_uuid');
		
		$i = 0;
		
		for (sort {$o{$a}{group_name} <=> $o{$b}{group_name}} keys %o) {
			push @options, {"user_groups[$i][group_name]" => $o{$_}{group_name},
							"user_groups[$i][user_group_uuid]"  => $o{$_}{user_group_uuid},
							"user_groups[$i][group_name]"  => $_
						   };
			$i++;
							
		}
		
		$hash{1}{user_groups}  = \@options;
		
    &print_json_response(%response);
}

sub deleteuser () {
    local $user_uuid = &database_clean_string(substr $form{user_uuid}, 0, 50);
    local %domain    = &get_domain();
   local %post_add = (); 
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    %hash = &database_select_as_hash(
                "select
                    1,user_uuid
                from
                    v_users
                where
                    user_uuid='$user_uuid'
                    and domain_uuid='$domain{uuid}'",
                'user_uuid');
    
    if (!$hash{1}{user_uuid}) {
        $response{stat}		= "fail";
        $response{message}	= "usr not found";       
    } else {

	##Date :18-8-23 Added by Atul for delete api

        $post_add{apirequest}="true";
	$post_add{id}=$user_uuid;
        &post_data (
            'domain_uuid' => $domain{uuid},
            #'urlpath'     => '/core/users/userdelete.php' . "?id=$user_uuid",
            #'urlpath'     => '/core/users/users.php' . "?id=$user_uuid",
            'urlpath'     => '/core/users/users.php',
            'reload'      => 0,
            ##'data'        => []);
            'data'        => [%post_add]);
        $response{stat}   = 'ok';
        $response{stat11}   = %post_add;
        
    }
    &print_json_response(%response);    
}

sub deleteusergroup () {
    local $user_uuid = &database_clean_string(substr $form{user_uuid}, 0, 50);
    local %domain    = &get_domain();
    
    if (!$domain{name}) {
        &print_api_error_end_exit(100, "$form{domain_name}/$form{domain_uuid} " . &_("not exists"));
    }
    
    local $group_name = &database_clean_string(substr $form{group_name}, 0, 50);
    if (!$group_name) {
        &print_api_error_end_exit(100, "group_name is null");
    }
    
	%hash = &database_select_as_hash(
                "select
                    1,user_uuid
                from
                    v_users
                where
                    user_uuid='$user_uuid'
                    and domain_uuid='$domain{uuid}'",
                'user_uuid');
    
    if (!$hash{1}{user_uuid}) {
        &print_api_error_end_exit(100, "user_uuid not exist");    
    }
	
# Date :- 19-Mar-2021 Added by Atul for get user group uuid
	$sql="SELECT 1,group_uuid as group_uuid_name from v_groups where group_name='$group_name'";
	%data = &database_select_as_hash($sql,"group_uuid_name");
	$group_uuid_name=$data{1}{group_uuid_name};
# end 
  ##Added By Hemant for check user group is exist or not 
	  if (!$group_uuid_name) {
		&print_api_error_end_exit(100, "group_name not exist");
	  }
  ##End
    &post_data (
        'domain_uuid' => $domain{uuid},
        #'urlpath'     => "/core/users/usersupdate.php?id=$user_uuid&domain_uuid=$domain{uuid}&group_name=$group_name&a=delete",
	'urlpath'     => "/core/users/user_edit.php?id=$user_uuid&domain_uuid=$domain{uuid}&group_name=$group_name&group_uuid=$group_uuid_name&a=delete",
        'reload'      => 1,
        'data'        => []
    );        
    
# Date :- 19-Mar-2021 Added by Atul For send response 
    $response{user_uuid}=$user_uuid;
    $response{stat}="OK";
    
# End 
    &print_json_response(%response);
}

1;
