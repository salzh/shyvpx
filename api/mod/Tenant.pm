=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

sub addtenant () {
    $name  = &database_clean_string(substr($form{domain_name},0,255));
    $name  = "\L$name";
    $tenant_did = &database_clean_string(substr($form{tenant_did},0,255));
    $descr = &database_clean_string(substr($form{domain_description},0,255));
    $domain_name = $name . ($app{base_domain} ? ".$app{base_domain}" : '');
    #Added by Hemant 21-07-21
	$object_expiration_enable = &database_clean_string($form{object_expiration_enable}) || '';
	$object_expiration_days = &database_clean_string(substr($form{object_expiration_days},0,50));
	$voicemail_object_expiration_enable = &database_clean_string($form{voicemail_object_expiration_enable}) || '';
	$voicemail_object_expiration_days = &database_clean_string(substr($form{voicemail_object_expiration_days},0,50));
	$domain_video_codec = &database_clean_string($form{domain_video_codec}) || 'false';
	$api_access = &database_clean_string($form{api_access}) || 'true';
	$telnyx_billing_enable = &database_clean_string($form{telnyx_billing_enable}) || 'true';
    $domain_enabled = &database_clean_string($form{domain_enabled}) || 'true';
    #End
    %response = ();
	
    %hash  = &database_select_as_hash("select
										1, domain_uuid
									from
										v_domains
									where
										domain_name='$domain_name'",
									'uuid');
    if ($hash{1}{uuid}) {
        $response{stat}				 = "fail";
        $response{message}			 = "$name already exists!";
        $response{data}{domain_uuid} = $hash{1}{uuid};
        
    	&print_json_response(%response);        
    }
    
    if ($response{stat} ne 'fail') {
        &post_data ( 'domain'    => '',
			'urlpath'   => '/core/domain_settings/domain_edit.php',
			'reload'	=> 1,
			'data'   =>  [
				'domain_name' => $domain_name,
				'domain_description' => $descr,
				'tenant_did' => $tenant_did,
				'domain_video_codec' => $domain_video_codec,
				'domain_enabled' => $domain_enabled,
				'telnyx_billing_enable' => $telnyx_billing_enable,
				'api_access' => $api_access,
				'object_expiration_enable' => $object_expiration_enable,
				'object_expiration_days' => $object_expiration_days,
				'voicemail_object_expiration_enable' => $voicemail_object_expiration_enable,
				'voicemail_object_expiration_days' => $voicemail_object_expiration_days,
				'submit' => 'Save'
			]
        );
        
        %hash  = &database_select_as_hash("select
											1, domain_uuid
										from
											v_domains
										where
											domain_name='$domain_name'",
										'uuid');
        if ($hash{1}{uuid}) {
            $response{stat}					= "ok";
            $response{data}{domain_uuid}    = $hash{1}{uuid};
        } else {
            $response{stat}			= "fail";
            $response{message}		= "$name not saved, pls contact administrator";
        }
        
        &print_json_response(%response); 
    }
}

sub edittenant () {	
	$name  = &database_clean_string(substr($form{domain_name},0,255));
    $name  = "\L$name";
    $descr = &database_clean_string(substr($form{domain_description},0,255));
    $domain_name = $name . ($app{base_domain} ? ".$app{base_domain}" : '');
    $uuid  = &clean_str(substr($form{domain_uuid},0,50),"MINIMAL","-_");
    #Added by Hemant 21-07-21
	$telnyx_billing_enable = &database_clean_string($form{telnyx_billing_enable}) || 'true';
    $domain_video_codec = &database_clean_string($form{domain_video_codec}) || 'false';
    $api_access = &database_clean_string($form{api_access}) || '';
	$domain_enabled = &database_clean_string($form{domain_enabled}) || 'true';
	$object_expiration_enable = &database_clean_string($form{object_expiration_enable}) || 'false';
	$object_expiration_days = &database_clean_string(substr($form{object_expiration_days},0,50));
	$voicemail_object_expiration_enable = &database_clean_string($form{voicemail_object_expiration_enable}) || 'false';
	$voicemail_object_expiration_days = &database_clean_string(substr($form{voicemail_object_expiration_days},0,50));
    #End
	
    %response = ();
	$pbx_host	= &websession_get("pbx_host");
	
    if ($pbx_host eq $domain_name and $api_access ne ''){
		$api_access = '';
        &print_api_error_end_exit(90, "Make api_access blank you cannot Enable/Disable it by your own Tenant\n" . &_(""));
    }
	

    if ($response{stat} ne 'fail') {
	
        &post_data ( 'domain'    => '',
			'urlpath'   => "/core/domain_settings/domain_edit.php?id=$uuid",
			'reload'	=> 1,
			'data'   =>  [
				'domain_name' => $domain_name,
				'domain_description' => $descr,
				'domain_uuid'	=> $uuid,
				'domain_video_codec' => $domain_video_codec,
				'telnyx_billing_enable' => $telnyx_billing_enable,
				'api_access' => $api_access,
				'domain_enabled' => $domain_enabled,
				'object_expiration_enable' => $object_expiration_enable,
				'object_expiration_days' => $object_expiration_days,
				'voicemail_object_expiration_enable' => $voicemail_object_expiration_enable,
				'voicemail_object_expiration_days' => $voicemail_object_expiration_days,
				'submit' => 'Save'
			]
        );
		
		$response{stat} = "ok";
		$response{data}{domain_uuid} = $uuid;

        &print_json_response(%response); 
    }   	
}

sub deletetenant () {
	$uuid  = &clean_str(substr($form{domain_uuid},0,50),"MINIMAL","-_");
	
	%hash  = &database_select_as_hash("select
											1,domain_uuid
										from
											v_domains
										where
											domain_uuid='$uuid'",
										'uuid');
	
		if (!$hash{1}{uuid})  {
            $response{stat}			= "fail";
            $response{message}		= "UUID not Exist !";
        }	
		
		&post_data ( 'domain'   => '',
				'urlpath'   => "/core/domain_settings/domain_delete.php?id=$uuid",
				'reload'	=> 1,
				'data'   =>  []
				);
	
		
        if ($hash{1}{uuid}) {
            $response{stat}	= "ok";
			$response{uuid}	= $uuid
        }
	
    &print_json_response(%response); 
   
}

sub gettenantlist () {
	#$uuid  = &clean_str(substr($form{domain_uuid},0,50),"MINIMAL","-_");

	%hash  = &database_select_as_hash("select
										domain_uuid,domain_name,domain_description
									from
										v_domains",
									'name,descr');
	
	$list  = [];
	for (sort {$hash{$a}{name} cmp $hash{$b}{name}} keys %hash) {
		push @$list, {domain_uuid => $_, domain_name => $hash{$_}{name},domain_description => $hash{$_}{descr}};
	}
	
    $response{stat}			= "ok";
	$response{data}{tenant_list}	= $list;
	
	&print_json_response(%response);

}

sub gettenant () {	
    $uuid  = &database_clean_string(substr $form{domain_uuid},0,50);
	
	%hash  = &database_select_as_hash("select
										1,dom.domain_uuid,dom.domain_name,dom.domain_description,dom.domain_enabled,
										vc.video_codec_enabled,vc.codec_string,vc.api_access,
										exs3.object_expiration_enable,
										exs3.object_expiration_days,
										exs3.voicemail_object_expiration_enable,
										exs3.voicemail_object_expiration_days
									from
										v_domains dom,v_video_codecs vc, v_s3_object_expiration exs3
									where
										dom.domain_uuid='$uuid' and vc.domain_uuid='$uuid' and exs3.domain_uuid='$uuid'",
									'uuid,name,descr,domain_enabled,video_codec_enabled,codec_string,api_access,object_expiration_enable,object_expiration_days,voicemail_object_expiration_enable,voicemail_object_expiration_days');

	
	if ($hash{1}{uuid}) {
		$response{stat}					= "ok";
		$response{data}{domain_uuid}    = $hash{1}{uuid};
		$response{data}{domain_name}    = $hash{1}{name};
		$response{data}{domain_description}    = $hash{1}{descr};
		$response{data}{domain_enabled}    = $hash{1}{domain_enabled};
		$response{data}{video_codec_enabled}    = $hash{1}{video_codec_enabled};
		$response{data}{codec_string}    = $hash{1}{codec_string};
		$response{data}{api_access}    = $hash{1}{api_access};
		$response{data}{rec_object_expiration_enable} = $hash{1}{object_expiration_enable};
		$response{data}{rec_object_expiration_days} = $hash{1}{object_expiration_days};
		$response{data}{voicemail_object_expiration_enable} = $hash{1}{voicemail_object_expiration_enable};
		$response{data}{voicemail_object_expiration_days} = $hash{1}{voicemail_object_expiration_days};

	} else {
		$response{stat}			= "fail";
		$response{message}		= "tenant not found by uuid=$uuid";
	}
	
	&print_json_response(%response);
}

sub switchtenant () {
	%domain           = &get_domain();

	if (!$domain{name}) {
		$response{stat}		= "fail";
		$response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
	}
	
	&change_domain($domain{uuid});
	$response{stat}			= "ok";
	$response{message}		= "ok";
	&print_json_response(%response);
}

return 1;
