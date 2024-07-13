local $poststring_add = '
device_mac_address:00:26:b6:7d:2f:5d
device_uuid:
device_label:
device_template:yealink/t28p
domain_uuid:
device_lines[0][device_line_uuid]:879b9f9b-e69d-4181-9d81-f6775341dd7d
device_lines[0][line_number]:1
device_lines[0][server_address]:pbx.fusionpbx.cn
device_lines[0][outbound_proxy_primary]:192.168.1.185
device_lines[0][outbound_proxy_secondary]:192.168.1.186
device_lines[0][outbound_proxy]:
device_lines[0][display_name]:1000
device_lines[0][user_id]:1000
device_lines[0][auth_id]:1000
device_lines[0][password]:123456
device_lines[0][sip_port]:
device_lines[0][sip_transport]:tcp
device_lines[0][register_expires]:
device_keys[0][device_key_uuid]:879b9f9b-e69d-4181-9d81-f6775341dd7d
device_keys[0][device_key_category]:line
device_keys[0][device_key_id]:1
device_keys[0][device_key_type]:BLF
device_keys[0][device_key_line]:1
device_keys[0][device_key_value]:1001
device_keys[0][device_key_vendor]:yealink
device_keys[0][device_key_label]:1001
device_keys[0][device_key_extension]:1001
device_settings[0][device_setting_uuid]:62a49571-0f89-4ee9-b9e5-4d5ddaa9233b
device_settings[0][device_setting_subcategory]:
device_settings[0][device_setting_value]:
device_settings[0][device_setting_enabled]:true
device_settings[0][device_setting_description]:
device_vendor:Yealink
device_user_uuid:879b9f9b-e69d-4181-9d81-f6775341dd7d
device_username:Hemant
device_password:Vin@123
device_model:
device_firmware_version:
device_uuid_alternate:879b9f9b-e69d-4181-9d81-f6775332aa7d
domain_uuid:879b9f9b-e69d-4181-9d81-f6775341cc7d
device_enabled:true
device_description:Test
';

sub adddevice () {
	
local $poststring_add = '
device_uuid:879b9f9b-e69d-4181-9d81-f6775341dd7d
device_mac_address:00:26:b6:7d:2f:5d
device_label:Yealink28
device_template:yealink/t28p
device_lines[0][device_line_uuid]:879b9f9b-e69d-4181-9d81-f6775341dd7d
device_lines[0][line_number]:1
device_lines[0][server_address]:pbx.fusionpbx.com
device_lines[0][outbound_proxy_primary]:192.168.1.185
device_lines[0][outbound_proxy_secondary]:192.168.1.186
device_lines[0][display_name]:1000
device_lines[0][user_id]:1000
device_lines[0][auth_id]:1000
device_lines[0][password]:1234
device_lines[0][sip_port]:
device_lines[0][sip_transport]:tcp
device_lines[0][register_expires]:
device_keys[0][device_key_uuid]:879b9f9b-e69d-4181-9d81-f6775341dd7d
device_keys[0][device_key_category]:line
device_keys[0][device_key_id]:1
device_keys[0][device_key_type]:BLF
device_keys[0][device_key_line]:1
device_keys[0][device_key_value]:1001
device_keys[0][device_key_vendor]:yealink
device_keys[0][device_key_label]:1001
device_keys[0][device_key_extension]:1001
device_settings[0][device_setting_uuid]:62a49571-0f89-4ee9-b9e5-4d5ddaa9233b
device_settings[0][device_setting_subcategory]:
device_settings[0][device_setting_value]:
device_settings[0][device_setting_enabled]:true
device_settings[0][device_setting_description]:
device_vendor:Yealink
device_user_uuid:879b9f9b-e69d-4181-9d81-f6775341dd7d
device_username:Hemant
device_password:Vin@123
device_model:
device_firmware_version:
device_uuid_alternate:879b9f9b-e69d-4181-9d81-f6775332aa7d
domain_uuid:879b9f9b-e69d-4181-9d81-f6775341cc7d
device_enabled:true
device_description:Test
';

local %post_add = ();
    for (split /\n/, $poststring_add) {
        ($key, $val) = split ':', $_, 2;
        next if !$key;
        $post_add{$key} = $val;
    }
    $response  = ();
   
	%post_add = ();
    %response       = ();   
    %domain         = &get_domain();
	
	
		local %params= (
			device_mac_address => {type => 'string', maxlen => 50, notnull => 1, default => ''},
			device_label => {type => 'string', maxlen => 50, notnull => 0, default => ''},
			device_template => {type => 'string', maxlen => 50, notnull => 1, default => ''},
			device_vendor => {type => 'string', maxlen => 50, notnull => 1, default => ''},
			device_user_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
			device_username => {type => 'string', maxlen => 50, notnull => 0, default => ''},
			device_password => {type => 'string', maxlen => 50, notnull => 0, default => ''},
			device_uuid_alternate => {type => 'string', maxlen => 50, notnull => 0, default => ''},
			device_enabled => {type => 'bool', maxlen => 50, notnull => 0, default => 'true'},
			device_model => {type => 'string', maxlen => 50, notnull => 0, default => ''},
			device_firmware_version => {type => 'string', maxlen => 50, notnull => 0, default => ''},
			#device_uuid => {type => 'string', maxlen => 200, notnull => 1, default => ''},
			device_description => {type => 'string', maxlen => 50, notnull => 0, default => ''}
		);
		
 
		for (0..11) {
			if (defined $form{'device_lines[' . $_ . '][line_number]'}) {
				#$params{'device_lines[' . $_ . '][device_line_uuid]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][line_number]'} = {type => 'int', maxlen => 2, notnull => 0, default => '1'};
				$params{'device_lines[' . $_ . '][outbound_proxy_primary]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][outbound_proxy_secondary]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][server_address]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][display_name]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][user_id]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][auth_id]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][password]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][sip_port]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][sip_transport]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][register_expires]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][enabled]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
			} else {
				last;
			}
		}
		
		for (0..99) {
			if (defined $form{'device_keys[' . $_ .'][device_key_id]'}) {
				$params{'device_keys[' . $_ . '][device_key_id]'} = {type => 'int', maxlen => 2, notnull => 0, default => '1'};
				$params{'device_keys[' . $_ . '][device_key_category]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_keys[' . $_ . '][device_key_type]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_keys[' . $_ . '][device_key_line]'} = {type => 'int', maxlen => 200, notnull => 0, default => ''};
				$params{'device_keys[' . $_ . '][device_key_value]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_keys[' . $_ . '][device_key_vendor]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_keys[' . $_ . '][device_key_label]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_keys[' . $_ . '][device_key_extension]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				#$params{'device_keys[' . $_ . '][device_key_uuid]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
			} else {
				last;
			}
		}
		
		for (0..99) {
			if (defined $form{'device_settings[' . $_ .'][device_setting_enabled]'}) {
				$params{'device_settings[' . $_ . '][device_setting_enabled]'} = {type => 'bool', maxlen => 200, notnull => 0, default => 'true'};
				#$params{'device_settings[' . $_ . '][device_setting_uuid]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_settings[' . $_ . '][device_setting_subcategory]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_settings[' . $_ . '][device_setting_value]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_settings[' . $_ . '][device_setting_description]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
			} else {
				last;
			}
		}
	
		if (!$domain{name}) {
			$response{stat}		= "fail";
			$response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
		}
		
		if (!$response{stat}) {
		   for $k (keys %params) {
				$tmpval   = '';
				if (&getvalue(\$tmpval, $k, $params{$k})) {
					$post_add{$k} = $tmpval;
				} 
				else {
					$response{stat}		= "fail";
					$response{message}	= $k. &_(" not valid");
				}
		   }
		}
		
		if (!$response{stat}) {
			$post_add{domain_uuid} = $domain{uuid};
			$result = &post_data (
				'domain_uuid' => $domain{uuid},
				'urlpath'     => '/app/devices/device_edit.php?id=' . $post_add{device_uuid},
				'reload'      => 1,
				'data'        => [%post_add]);
		
		
		%hash = &database_select_as_hash(
										 "select
											  1,device_uuid,v_devices.*
										  from
											  v_devices
										  where
											  domain_uuid='$domain{uuid}' and
											  device_label='$post_add{device_label}'",
										  'device_uuid',
										  "device_uuid");
										  
		
			 if ($hash{1}{device_uuid}){
				 
				$response{stat}		= "ok";
				$response{message}	= "OK";
				$response{timestamp} = time;
				$response{data}{device_uuid} = $hash{1}{device_uuid};
			
			 }else{
				 $response{stat}		= "fail";
				 $response{message}	= "device_uuid " . &_("not exists");
			 }
			
		}
		
   	&print_json_response(%response);
}

sub editdevice () {
	
local $poststring_add = '
device_uuid:879b9f9b-e69d-4181-9d81-f6775341dd7d
device_mac_address:00:26:b6:7d:2f:5d
device_label:Yealink28
device_template:yealink/t28p
device_lines[0][device_line_uuid]:879b9f9b-e69d-4181-9d81-f6775341dd7d
device_lines[0][line_number]:1
device_lines[0][server_address]:pbx.fusionpbx.com
device_lines[0][outbound_proxy_primary]:192.168.1.185
device_lines[0][outbound_proxy_secondary]:192.168.1.186
device_lines[0][display_name]:1000
device_lines[0][user_id]:1000
device_lines[0][auth_id]:1000
device_lines[0][password]:1234
device_lines[0][sip_port]:
device_lines[0][sip_transport]:tcp
device_lines[0][register_expires]:
device_keys[0][device_key_uuid]:879b9f9b-e69d-4181-9d81-f6775341dd7d
device_keys[0][device_key_category]:line
device_keys[0][device_key_id]:1
device_keys[0][device_key_type]:BLF
device_keys[0][device_key_line]:1
device_keys[0][device_key_value]:1001
device_keys[0][device_key_vendor]:yealink
device_keys[0][device_key_label]:1001
device_keys[0][device_key_extension]:1001
device_settings[0][device_setting_uuid]:62a49571-0f89-4ee9-b9e5-4d5ddaa9233b
device_settings[0][device_setting_subcategory]:
device_settings[0][device_setting_value]:
device_settings[0][device_setting_enabled]:true
device_settings[0][device_setting_description]:
device_vendor:Yealink
device_user_uuid:879b9f9b-e69d-4181-9d81-f6775341dd7d
device_username:Hemant
device_password:Vin@123
device_model:
device_firmware_version:
device_uuid_alternate:879b9f9b-e69d-4181-9d81-f6775332aa7d
domain_uuid:879b9f9b-e69d-4181-9d81-f6775341cc7d
device_enabled:true
device_description:Test
';

local %post_add = ();
    for (split /\n/, $poststring_add) {
        ($key, $val) = split ':', $_, 2;
        next if !$key;
        $post_add{$key} = $val;
    }
    $response  = ();
   
	%post_add = ();
    %response       = ();   
    %domain         = &get_domain();
	
	
		local %params= (
			device_mac_address => {type => 'string', maxlen => 50, notnull => 1, default => ''},
			device_label => {type => 'string', maxlen => 50, notnull => 0, default => ''},
			device_template => {type => 'string', maxlen => 50, notnull => 1, default => ''},
			device_vendor => {type => 'string', maxlen => 50, notnull => 0, default => ''},
			device_user_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
			device_username => {type => 'string', maxlen => 50, notnull => 0, default => ''},
			device_password => {type => 'string', maxlen => 50, notnull => 0, default => ''},
			device_uuid_alternate => {type => 'string', maxlen => 50, notnull => 0, default => ''},
			device_enabled => {type => 'bool', maxlen => 50, notnull => 0, default => 'true'},
			device_model => {type => 'string', maxlen => 50, notnull => 0, default => ''},
			device_firmware_version => {type => 'string', maxlen => 50, notnull => 0, default => ''},
			device_uuid => {type => 'string', maxlen => 200, notnull => 1, default => ''},
			device_description => {type => 'string', maxlen => 50, notnull => 0, default => ''}
		);
		
        $device_uuid =  &clean_str($form{device_uuid}, "-_");
		
		%hash = &database_select_as_hash(
										 "select
											  1,device_uuid
										  from
											  v_devices
										  where
											  domain_uuid='$domain{uuid}' and
											  device_uuid='$device_uuid'",
										  'device_uuid',
										  "device_uuid");
										  		 
		 if (!$hash{1}{device_uuid}){
			 $response{stat}		= "fail";
			 $response{message}	= "device_uuid " . &_("not exists");
		 }
		 
		for (0..11) {
			if (defined $form{'device_lines[' . $_ . '][line_number]'}) {
				$params{'device_lines[' . $_ . '][device_line_uuid]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][line_number]'} = {type => 'int', maxlen => 2, notnull => 0, default => '1'};
				$params{'device_lines[' . $_ . '][outbound_proxy_primary]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][outbound_proxy_secondary]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][server_address]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][display_name]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][user_id]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][auth_id]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][password]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][sip_port]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][sip_transport]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][register_expires]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_lines[' . $_ . '][enabled]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
			} else {
				last;
			}
		}
		
		for (0..99) {
			if (defined $form{'device_keys[' . $_ .'][device_key_id]'}) {
				$params{'device_keys[' . $_ . '][device_key_id]'} = {type => 'int', maxlen => 2, notnull => 0, default => '1'};
				$params{'device_keys[' . $_ . '][device_key_category]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_keys[' . $_ . '][device_key_type]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_keys[' . $_ . '][device_key_line]'} = {type => 'int', maxlen => 200, notnull => 0, default => ''};
				$params{'device_keys[' . $_ . '][device_key_value]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_keys[' . $_ . '][device_key_vendor]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_keys[' . $_ . '][device_key_label]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_keys[' . $_ . '][device_key_extension]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_keys[' . $_ . '][device_key_uuid]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
			} else {
				last;
			}
		}
		
		for (0..99) {
			if (defined $form{'device_settings[' . $_ .'][device_setting_enabled]'}) {
				$params{'device_settings[' . $_ . '][device_setting_enabled]'} = {type => 'bool', maxlen => 200, notnull => 0, default => 'true'};
				$params{'device_settings[' . $_ . '][device_setting_uuid]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_settings[' . $_ . '][device_setting_subcategory]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_settings[' . $_ . '][device_setting_value]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
				$params{'device_settings[' . $_ . '][device_setting_description]'} = {type => 'string', maxlen => 200, notnull => 0, default => ''};
			} else {
				last;
			}
		}
	
		if (!$domain{name}) {
			$response{stat}		= "fail";
			$response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
		}
		
		if (!$response{stat}) {
		   for $k (keys %params) {
				$tmpval   = '';
				if (&getvalue(\$tmpval, $k, $params{$k})) {
					$post_add{$k} = $tmpval;
				} 
				else {
					$response{stat}		= "fail";
					$response{message}	= $k. &_(" not valid");
				}
		   }
		}
		
		if (!$response{stat}) {
			$post_add{domain_uuid} = $domain{uuid};
			$result = &post_data (
				'domain_uuid' => $domain{uuid},
				'urlpath'     => '/app/devices/device_edit.php?id=' . $post_add{device_uuid},
				'reload'      => 1,
				'data'        => [%post_add]);
			#warn $result->header("Location");
			$response{stat}		= "ok";
			$response{message}	= "OK";
			$response{timestamp} = time;
			$response{data}{device_uuid} = $device_uuid;
			
		}
		
   	&print_json_response(%response);
}

sub getdevicelist () {
    local %params = (
        device_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_mac_address => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        device_label => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        device_template => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        device_vendor => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        device_model => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        device_firmware_version => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        device_enabled => {type => 'bool', maxlen => 50, notnull => 0, default => ''},
        device_description => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		device_uuid_alternate => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		device_provisioned_date => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		device_provisioned_method => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		device_provisioned_ip => {type => 'string', maxlen => 50, notnull => 0, default => ''},
    );
    
    %domain = &get_domain();

    if (!$domain{name}) {
        $response{stat}		= "fail";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    if (!$response{stat}) {
		
        $fields = join ",", keys %params;
    
        %hash = &database_select_as_hash_with_key ("
                    select
                        device_uuid,v_devices.*
                    from
                        v_devices
                    where
                        domain_uuid='$domain{uuid}'",
                    'device_uuid',
                    "$fields");
       
        $response{stat}		= "ok";
        $response{message}	= "OK";
        $response{timestamp} = time;
		
		#$status = "$hash{$_}{device_provisioned_date}"-"$hash{$_}{device_provisioned_method}"-"$hash{$_}{device_provisioned_ip}";
        
		for (keys %hash) {
            push @{$response{data}}, $hash{$_};
        }
    }   
      
  	&print_json_response(%response);      
}

sub getdevice() {   
    local %params= (
        device_uuid => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        device_mac_address => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        device_label => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        device_template => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        device_vendor => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        device_model => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        device_firmware_version => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        device_enabled => {type => 'bool', maxlen => 50, notnull => 0, default => ''},
        device_description => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		device_user_uuid => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		device_username => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		device_password => {type => 'string', maxlen => 50, notnull => 0, default => ''},
		device_uuid_alternate => {type => 'string', maxlen => 50, notnull => 0, default => ''}
    );
    
    $uuid =  &clean_str($form{device_uuid}, "-_");
    %domain = &get_domain();

    if (!$domain{name}) {
        $response{stat}		= "fail";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }

    if (!$response{stat}) {

        $fields = join ",", keys %params;
		 
        %hash = &database_select_as_hash ("
                    select
                        1,$fields
                    from
                        v_devices
                    where
                        device_uuid='$uuid' and domain_uuid='$domain{uuid}'",
                    "$fields");
							
        if (!$hash{1}{device_uuid}) {
            $response{stat}		= "fail";
            $response{message}	= &_("not found device");
        } else {
            
			 @device_lines = ();
			%line = &database_select_as_hash ("
                                            select
                                                device_line_uuid,line_number,server_address,outbound_proxy_primary,display_name,user_id,auth_id,password,sip_port,sip_transport,register_expires,enabled
                                            from
                                                v_device_lines
                                            where
                                                device_uuid='$uuid'",
                                            "line_number,server_address,outbound_proxy_primary,display_name,user_id,auth_id,password,sip_port,sip_transport,register_expires,enabled");
            
            $i = 0;
            for (sort {$line{$a}{line_number} <=> $line{$b}{line_number}} keys %line) {
				push @device_lines, {"device_lines[$i][line_number]" => $line{$_}{line_number},
								"device_lines[$i][server_address]" => $line{$_}{server_address},
								"device_lines[$i][outbound_proxy_primary]" => $line{$_}{outbound_proxy_primary},
								"device_lines[$i][display_name]" => $line{$_}{display_name},
								"device_lines[$i][user_id]" => $line{$_}{user_id},
								"device_lines[$i][auth_id]" => $line{$_}{auth_id},
								"device_lines[$i][password]" => $line{$_}{password},
								"device_lines[$i][sip_port]" => $line{$_}{sip_port},
								"device_lines[$i][sip_transport]" => $line{$_}{sip_transport},
								"device_lines[$i][register_expires]" => $line{$_}{register_expires},
								"device_lines[$i][enabled]" => $line{$_}{enabled},
								"device_lines[$i][device_line_uuid]" => $_
				};
                $i++;                
            }
			
            @device_keys = ();
            %key = &database_select_as_hash ("
											select
												device_key_uuid,device_key_id,device_key_category,device_key_type,device_key_line,device_key_value,device_key_extension,device_key_label
											from
												v_device_keys
											where
												device_uuid='$uuid' and domain_uuid='$domain{uuid}'",
											"device_key_id,device_key_category,device_key_type,device_key_line,device_key_value,device_key_extension,device_key_label");
            
            $i = 0;
            for (sort {$key{$a}{device_key_id} <=> $key{$b}{device_key_id}} keys %key) {
               push @device_keys, {"device_keys[$i][device_key_id]"   => $key{$_}{device_key_id},
							   "device_keys[$i][device_key_type]" => $key{$_}{device_key_type},
							   "device_keys[$i][device_key_line]" => $key{$_}{device_key_line},
							   "device_keys[$i][device_key_value]" => $key{$_}{device_key_value},
							   "device_keys[$i][device_key_extension]" => $key{$_}{device_key_extension},
							   "device_keys[$i][device_key_label]" => $key{$_}{device_key_label},
							   "device_keys[$i][device_key_category]" => $key{$_}{device_key_category},
							   "device_keys[$i][device_key_uuid]" => $_
							   
							  };
				
                $i++;
            }
			
			@device_settings = ();
            %settings = &database_select_as_hash ("
												select
													device_setting_uuid,device_setting_category,device_setting_subcategory,device_setting_name,device_setting_value,device_setting_enabled,device_setting_description
												from
													v_device_settings
												where
													device_uuid='$uuid'",
												"device_setting_category,device_setting_subcategory,device_setting_name,device_setting_value,device_setting_enabled,device_setting_description");
										
            $i = 0;
            for (sort {$settings{$a}{device_setting_name} <=> $settings{$b}{device_setting_name}} keys %settings) {
                push @device_settings, {"device_settings[$i][device_setting_category]"  => $settings{$_}{device_setting_category},
										"device_settings[$i][device_setting_subcategory]"   => $settings{$_}{device_setting_subcategory},
										"device_settings[$i][device_setting_value]"   => $settings{$_}{device_setting_value},
										"device_settings[$i][device_setting_enabled]"   => $settings{$_}{device_setting_enabled},
										"device_settings[$i][device_setting_name]"   => $settings{$_}{device_setting_name},
										"device_settings[$i][device_setting_description]"  => $settings{$_}{device_setting_description},
										"device_settings[$i][device_setting_uuid]"   => $_
									};
                $i++;                
            }
			
			
			 $hash{1}{device_lines}  = \@device_lines; 
			 $hash{1}{device_keys} = \@device_keys;
			 $hash{1}{device_settings} = \@device_settings;
			 $response{data} = $hash{1};
			 $response{stat} = "ok";
			 $response{message}	= "OK";
			 $response{timestamp} = time;
        }
    }
    
    &print_json_response(%response);          
}

sub deletedevice () {
	%domain = &get_domain();
	  
    $device_uuid = &database_clean_string(substr $form{device_uuid}, 0, 50);
    
    %hash = &database_select_as_hash(
                "select
                    1,device_uuid
                from
                    v_devices
                where
                    domain_uuid='$domain{uuid}' and
                    device_uuid='$device_uuid'",
                'device_uuid'
    );
    
	$post_add{id}=$device_uuid;

    if ($hash{1}{device_uuid}) {
		
		if($device_uuid){
			$response{stat} = 'ok';
			$response{message} = "Ok";
			$response{timestamp} = time;
			&post_data (
				 'domain_uuid' => $domain{uuid},
				 'urlpath'     => "/app/devices/device_delete.php?id=$device_uuid",
				 'reload'      => 0,
				 'data'        => [%post_add]);    
		} else {
			$response{stat}    = 'fail';
			$response{message} = "device_uuid not found ";
		}
		
    }else{
		$response{stat}    = 'fail';
		$response{message} = "device_uuid not found";
	}
	
    &print_json_response(%response);
}

sub device_provision () {
	
	%domain = &get_domain();
	  
    $device_uuid = &database_clean_string(substr $form{device_uuid}, 0, 50);
	$provision_action = &database_clean_string(substr $form{provision_action}, 0, 50);
    
    %hash = &database_select_as_hash(
                "select
                    1,device_uuid
                from
                    v_devices
                where
                    domain_uuid='$domain{uuid}' and
                    device_uuid='$device_uuid'",
                'device_uuid'
    );
    

    if ($hash{1}{device_uuid}) {
			%hash = &database_select_as_hash(
					"select
						1,device_vendor
					from
						v_devices
					where
						domain_uuid='$domain{uuid}' and
						device_uuid='$device_uuid'",
					'device_vendor'

			);
						
			 if ($hash{1}{device_vendor}) {
				 
				    $device_vendor = $hash{1}{device_vendor};
					
					%hash = &database_select_as_hash(
							"select
								1,user_id
							from
								v_device_lines
							where
								domain_uuid='$domain{uuid}' and
								device_uuid='$device_uuid' and user_id IS NOT NULL LIMIT 1",
							'user_id'
					);
					
					if ($hash{1}{user_id}) {
						
						$user_id = $hash{1}{user_id};
						
						if ($provision_action == 'flush_inbound_reg'){
							$cmd = "sofia profile internal flush_inbound_reg $user_id\'@\'$domain{name} reboot";
							$output = &runswitchcommand('internal', $cmd);
						}else{
							$cmd = "lua app.lua event_notify internal $provision_action $user_id\'@\'$domain{name} $device_vendor";
							$output = &runswitchcommand('internal', $cmd);
						}

						$response{stat}    = 'ok';
						$response{message} = "Ok";
						$response{timestamp} = time;
						
					}else{
						$response{stat}    = 'fail';
						$response{message} = "user_id not found";
					}
					
			 }else{
				 $response{stat}    = 'fail';
				 $response{message} = "device vendor not found";
			 }
			
    }else{
		$response{stat}    = 'fail';
		$response{message} = "device_uuid not found";
	}
	
    &print_json_response(%response);
}
