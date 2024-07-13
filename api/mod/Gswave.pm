=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut

##################################################################
### Created and Developed by Hemant Chaudhary Date : 16/08/2021 ###
##################################################################

sub gswave_qr () {
	
   $extension = $form{extension};
   %response=();
   $response{stat}		= "ok";
	
   if (!$extension) {
      $response{stat}		= "fail";
      $response{message}	= &_("extension is null!");   
   }
   
   if ($response{stat} ne 'fail') {
      %domain   = &get_domain();

      if (!$domain{name}) {
         $response{stat}	= "fail";
         $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
      }
	  
   }
   
	%hash = &database_select_as_hash ("select
                                             1,extension_uuid,password
                                        from
                                             v_extensions
                                        where
                                             extension='$extension' and
                                             domain_uuid='$domain{uuid}'",
                                        'extension_uuid,password');
    
    if(!$hash{1}{extension_uuid}){
		 
	   $response{stat}	= "fail";
       $response{message}	= "Extension UUID " . &_("not exists");
	   
	}
   
	$password = $hash{1}{password};
	$uuid = $hash{1}{extension_uuid};
   
   if ($response{stat} ne 'fail') {   
	
		$domain_name = $domain{name};
	
		$curl="curl https://$domain_name/app/gswave/api_gswave.php?'id=$uuid\&extension=$extension\&password=$password'";
	
		my $curl = `$curl`;
		
		$result = encode_base64($curl);
		
		$result = join('',split(/\n/,$result));

		if(!$result){
			$response{stat}	= "fail";
			$response{message}	= "	Extension " . &_("not exists");
		}
		
		if ($result ne 'fail') {
		  $response{stat}	= "ok";
		  $response{message}= "OK";
		  $response{data}{result} = $result;
		}

   }
   
   &print_json_response(%response);   
}

return 1;

#######################################################
### 					END                         ###
#######################################################
