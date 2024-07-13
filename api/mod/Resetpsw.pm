=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut


sub resetpwd () {
    local %post_add = ();
    %response       = ();   
    %domain         = &get_domain();


  local %params = (
        user_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        password => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        confirmpassword => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        user_email => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        user_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'}
    ); 
	
	####Get Remote addredd for secure authentication
	
	use CGI qw( );
	my $cgi = CGI->new();
	$header = $cgi->header('text/plain');
	$addr = $cgi->remote_addr(), "\n";
	
	

	for $k (keys %params) {
        $tmpval   = '';
        if (&getvalue(\$tmpval, $k, $params{$k})) {
            $post_add{$k} = $tmpval;
        } else {
            $response{stat}	= "fail";
            $response{message}	= $k. &_(" not valid");
        }
    }
	
	###### If you got error of authorization change below IP with your server remote IP
	#### Allow your IP at the place of "my_ip_"
		
	%remote_addr = &database_select_as_hash("SELECT 1,ip FROM v_api_accessible_ips 
											WHERE ip = '$addr' LIMIT 1",
                                        'ip');

	if ($remote_addr{1}{ip} eq '') {
		&print_api_error_end_exit(110, "You are not authorized to perform this action!"); 
	}
	
	
	%user_data = &database_select_as_hash("select
                                            1,username
                                        from
                                            v_users
                                        where
                                            user_uuid='$post_add{user_uuid}'",
                                        'username');

	if ($user_data{1}{username} eq '') {
		&print_api_error_end_exit(110, "Invalid user_uuid!");  
	}
	
    $post_add{id} = $post_add{user_uuid};
    
    if ($post_add{password} ne $post_add{confirmpassword}) {
        &print_api_error_end_exit(110, "password/confirmpassword is not same");        
    }
		
     $post_add{username} = $user_data{1}{username};
     $post_add{domain_uuid} = $domain{uuid};

	%email_val = &database_select_as_hash("select
                                            1,con_email.email_address,us.user_uuid,us.contact_uuid
                                        from
                                            v_users as us, v_contact_emails as con_email
                                        where
                                            us.user_uuid='$post_add{user_uuid}' and
                                            us.domain_uuid='$post_add{domain_uuid}' and con_email.contact_uuid=us.contact_uuid",
                                        'email_address');

	if ($email_val{1}{email_address} ne $post_add{user_email}) {
         &print_api_error_end_exit(110, "Invalid Email Address!");  
    }
	
	
    if ($response{stat} ne 'fail') {    
        &post_data (
                'domain_uuid' => $domain{uuid},
                'urlpath'     => "/core/users/resetpassword.php?id=$post_add{id}",
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
										
        if ($hash{1}{uuid}) {
           $response{stat}		      = "ok";
		   $response{data}{email_address} = $email_val{1}{email_address};
		   $response{data}{remote_addr} = $addr;
           $response{data}{user_uuid} = $hash{1}{uuid};
        } else {
           $response{stat}		= "fail";
           $response{message}	= "$post_add{username} not saved!";
        }
        
    }
   
   &print_json_response(%response);
}
1;
