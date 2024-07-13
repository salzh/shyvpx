=pod
	Version 1.0
	Developed by Velantro inc
	Contributor(s):
	George Gabrielyan <george@velantro.com>
=cut


sub addtimecondition () {    
	local $poststring_add = '
dialplan_name:tc
dialplan_number:6001
dialplan_action:transfer:*9910002 XML default.domain.net
dialplan_anti_action:transfer:7001 XML default.domain.net
dialplan_order:300
default_preset_action:transfer:*9910002 XML default.domain.net
group_500:500
dialplan_enabled:true
dialplan_description:true
submit:Save
';

    local %post_add = ();
    for (split /\n/, $poststring_add) {
        ($key, $val) = split ':', $_, 2;
        next if !$key;

        $post_add{$key} = $val;
    }
    $response  = ();
	
    %domain   = &get_domain();
    local %params = (
        dialplan_name => {type => 'string', maxlen => 50, notnull => 1, default => ''},
        dialplan_number => {type => 'string', maxlen => 20, notnull => 1, default => 'destination_number'},
        condition_mday => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        condition_wday => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        condition_time_of_day => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        condition_mon => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        condition_mweek => {type => 'string', maxlen => 50, notnull => 0, default =>''},
        #condition_yday => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        condition_hour => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        condition_date_time => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        condition_week => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        condition_year => {type => 'string', maxlen => 50, notnull => 0, default => ''},
        dialplan_action => {type => 'string', maxlen => 255, notnull => 1, default => ''},
		default_preset_action=> {type => 'string', maxlen => 255, notnull => 0, default => ''},
		group_500 => {type => 'int', maxlen => 4, notnull => 0, default => '500'},
        dialplan_anti_action => {type => 'string', maxlen => 255, notnull => 0, default => ''},
        dialplan_order => {type => 'int', maxlen => 4, notnull => 0, default => '300'},
        dialplan_enabled => {type => 'bool', maxlen => 10, notnull => 0, default => 'true'},
        dialplan_description => {type => 'string', maxlen => 255, notnull => 0, default => ''},
		
    );
	 

    if (!$domain{name}) {
        $response{stat}		= "fail";
        $response{message}	= "$form{domain_name}/$form{domain_uuid} " . &_("not exists");
    }
    
    # if ($response{stat} ne 'fail') {
       # for $k (keys %params) {
            # $tmpval   = '';
            # if (&getvalue(\$tmpval, $k, $params{$k})) {
                # $post_add{$k} = $tmpval;
            # } else {
                # $response{stat}		= "fail";
                # $response{message}	= $k. &_(" not valid");
            # }
        # }
    # }
	
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
	
									
# $random1 = int(rand(1000));
$random2 = int(rand(1000));
$random3 = int(rand(1000));
$random4 = int(rand(1000));
$random5 = int(rand(1000));
$random6 = int(rand(1000));
$random7 = int(rand(1000));
$random8 = int(rand(1000));
$random9 = int(rand(1000));
$random10 = int(rand(1000));
$random11 = int(rand(1000));
$random12 = int(rand(1000));
$random13 = int(rand(1000));
$random14 = int(rand(1000));
$random15 = int(rand(1000));
$random16 = int(rand(1000));
$random17 = int(rand(1000));
$random18 = int(rand(1000));
$random19 = int(rand(1000));
$random20 = int(rand(1000));
$random21 = int(rand(1000));
$random22 = int(rand(1000));
$random23 = int(rand(1000));
$random24 = int(rand(1000));
$random25 = int(rand(1000));
$random26 = int(rand(1000));
$random27 = int(rand(1000));
$random28 = int(rand(1000));
$random29 = int(rand(1000));
$random30 = int(rand(1000));
$random31 = int(rand(1000));
$random32 = int(rand(1000));
$random33 = int(rand(1000));
$random34 = int(rand(1000));
$random35 = int(rand(1000));
$random36 = int(rand(1000));
$random37 = int(rand(1000));


## Date :- 31-Mar-2021 Added by Atul for fixing the api
$post_add{domain_uuid}=$domain{uuid};

$post_add{"group_500"} =$post_add{group_500};
#$post_add{"dialplan_action[$post_add{group_500}]"} =$post_add{dialplan_action};
	
#$post_add{"variable[custom][500][$random1]"} ="";

### Added By Hemant Chaudhari 30-Jun-2021 ###
if ($post_add{condition_year} != nil) {
	
	$list = $post_add{condition_year};
	# using split() function
	my @spl = split('-', $list);
	
	$post_add{"variable[custom][$post_add{group_500}][$random2]\n"} ="year";
	$post_add{"value[$post_add{group_500}][$random2][start]"} =$spl[0];
	$post_add{"value[$post_add{group_500}][$random2][stop]"} =$spl[1];
}

 if ($post_add{condition_mon} != nil) {
	 
	$list = $post_add{condition_mon};
	# using split() function
	my @spl1 = split('-', $list);
	
	$post_add{"variable[custom][$post_add{group_500}][$random3]\n"} ="mon";
	$post_add{"value[$post_add{group_500}][$random3][start]"} =$spl1[0];
	$post_add{"value[$post_add{group_500}][$random3][stop]"} =$spl1[1];
 }

 if ($post_add{condition_mday} != nil) {
	$list = $post_add{condition_mday};
	# using split() function
	my @spl2 = split('-', $list);
	$post_add{"variable[custom][$post_add{group_500}][$random5]\n"} ="mday";
	$post_add{"value[$post_add{group_500}][$random5][start]"} =$spl2[0];
	$post_add{"value[$post_add{group_500}][$random5][stop]"} =$spl2[1];
 }

 if ($post_add{condition_wday} != nil) {
	$list = $post_add{condition_wday};
	# using split() function
	my @spl3 = split('-', $list);
	
	$post_add{"variable[custom][$post_add{group_500}][$random6]\n"} ="wday";
	$post_add{"value[$post_add{group_500}][$random6][start]"} =$spl3[0];
	$post_add{"value[$post_add{group_500}][$random6][stop]"} =$spl3[1];
 }

if ($post_add{condition_week} != nil) {
	$list = $post_add{condition_week};
	# using split() function
	my @spl4 = split('-', $list);
	
	$post_add{"variable[custom][$post_add{group_500}][$random7]\n"} ="week";
	$post_add{"value[$post_add{group_500}][$random7][start]"} =$spl4[0];
	$post_add{"value[$post_add{group_500}][$random7][stop]"} =$spl4[1];
}

if ($post_add{condition_mweek} != nil) {
	$list = $post_add{condition_mweek};
	# using split() function
	my @spl5 = split('-', $list);
	
	$post_add{"variable[custom][$post_add{group_500}][$random8]\n"} ="mweek";
	$post_add{"value[$post_add{group_500}][$random8][start]"} =$spl5[0];
	$post_add{"value[$post_add{group_500}][$random8][stop]"} =$spl5[1];
}

if ($post_add{condition_hour} != nil) {
	$list = $post_add{condition_hour};
	# using split() function
	my @spl6 = split('-', $list);
	
	$post_add{"variable[custom][$post_add{group_500}][$random9]\n"} ="hour";
	$post_add{"value[$post_add{group_500}][$random9][start]"} =$spl6[0];
	$post_add{"value[$post_add{group_500}][$random9][stop]"} =$spl6[1];
}

if ($post_add{condition_time_of_day} != nil) {
	$list = $post_add{condition_time_of_day};
	# using split() function
	my @spl7 = split('-', $list);
	
	$post_add{"variable[custom][$post_add{group_500}][$random10]\n"} ="time-of-day";
	$post_add{"value[$post_add{group_500}][$random10][start]"} =$spl7[0];
	$post_add{"value[$post_add{group_500}][$random10][stop]"} =$spl7[1];
}

if ($post_add{condition_date_time} != nil) {
	$list = $post_add{condition_date_time};
	# using split() function
	my @spl8 = split('~', $list);
	
	$post_add{"variable[custom][$post_add{group_500}][$random11]\n"} ="date-time";
	$post_add{"value[$post_add{group_500}][$random11][start]"} =$spl8[0];
	$post_add{"value[$post_add{group_500}][$random11][stop]"} =$spl8[1];
}
$post_add{"dialplan_action[$post_add{group_500}]"} =$post_add{dialplan_action};
$post_add{"dialplan_action[105]"} ="";
$post_add{"dialplan_action[110]"} ="";
$post_add{"dialplan_action[115]"} ="";
$post_add{"dialplan_action[120]"} ="";
$post_add{"dialplan_action[125]"} ="";
$post_add{"dialplan_action[130]"} ="";
$post_add{"dialplan_action[135]"} ="";
$post_add{"dialplan_action[140]"} ="";
$post_add{"dialplan_action[145]"} ="";

#$post_add{"preset[4]"} ="120";
#$post_add{"preset[5]"} ="125";


#100
$post_add{"variable[preset][100][$random12]"} ="mday";
$post_add{"variable[preset][100][$random13]"} ="mon";
$post_add{"value[100][$random12][start]"} ="1";
$post_add{"value[100][$random12][stop]"} ="";
$post_add{"value[100][$random13][start]"} ="1";
$post_add{"value[100][$random13][stop]"} ="";

#105
$post_add{"variable[preset][105][$random14]"} ="wday";
$post_add{"variable[preset][105][$random15]"} ="mon";
$post_add{"variable[preset][105][$random16]"} ="mday";
$post_add{"value[105][$random14][start]"} ="2";
$post_add{"value[105][$random14][stop]"} ="";
$post_add{"value[105][$random15][start]"} ="2";
$post_add{"value[105][$random15][stop]"} ="";
$post_add{"value[105][$random16][start]"} ="15";
$post_add{"value[105][$random16][stop]"} ="21";

#110
$post_add{"variable[preset][110][$random17]"} ="mday";
$post_add{"variable[preset][110][$random18]"} ="wday";
$post_add{"variable[preset][110][$random19]"} ="mon";
$post_add{"value[110][$random17][start]"} ="25";
$post_add{"value[110][$random17][stop]"} ="31";
$post_add{"value[110][$random18][start]"} ="2";
$post_add{"value[110][$random18][stop]"} ="";
$post_add{"value[110][$random19][start]"} ="5";
$post_add{"value[110][$random19][stop]"} ="";

#115
$post_add{"variable[preset][115][$random20]"} ="mday";
$post_add{"variable[preset][115][$random21]"} ="mon";
$post_add{"value[115][$random20][start]"} ="4";
$post_add{"value[115][$random20][stop]"} ="";
$post_add{"value[115][$random21][start]"} ="7";
$post_add{"value[115][$random21][stop]"} ="";

#120
$post_add{"variable[preset][120][$random22]"} ="wday";
$post_add{"variable[preset][120][$random23]"} ="mon";
$post_add{"variable[preset][120][$random24]"} ="mday";
$post_add{"value[120][$random22][start]"} ="2";
$post_add{"value[120][$random22][stop]"} ="";
$post_add{"value[120][$random23][start]"} ="9";
$post_add{"value[120][$random23][stop]"} ="";
$post_add{"value[120][$random24][start]"} ="1";
$post_add{"value[120][$random24][stop]"} ="7";

#125
$post_add{"variable[preset][125][$random25]"} ="wday";
$post_add{"variable[preset][125][$random26]"} ="mon";
$post_add{"variable[preset][125][$random27]"} ="mday";
$post_add{"value[125][$random25][start]"} ="2";
$post_add{"value[125][$random25][stop]"} ="";
$post_add{"value[125][$random26][start]"} ="10";
$post_add{"value[125][$random26][stop]"} ="";
$post_add{"value[125][$random27][start]"} ="8";
$post_add{"value[125][$random27][stop]"} ="14";

#130
$post_add{"variable[preset][130][$random28]"} ="mday";
$post_add{"variable[preset][130][$random29]"} ="mon";
$post_add{"value[130][$random28][start]"} ="11";
$post_add{"value[130][$random28][stop]"} ="";
$post_add{"value[130][$random29][start]"} ="11";
$post_add{"value[130][$random29][stop]"} ="";

#135
$post_add{"variable[preset][135][$random30]"} ="wday";
$post_add{"variable[preset][135][$random31]"} ="mon";
$post_add{"variable[preset][135][$random32]"} ="mday";
$post_add{"value[135][$random30][start]"} ="5";
$post_add{"value[135][$random30][stop]"} ="6";
$post_add{"value[135][$random31][start]"} ="11";
$post_add{"value[135][$random31][stop]"} ="";
$post_add{"value[135][$random32][start]"} ="22";
$post_add{"value[135][$random32][stop]"} ="28";

#140
$post_add{"variable[preset][140][$random33]"} ="mday";
$post_add{"variable[preset][140][$random34]"} ="mon";
$post_add{"value[140][$random33][start]"} ="25";
$post_add{"value[140][$random33][stop]"} ="";
$post_add{"value[140][$random34][start]"} ="12";
$post_add{"value[140][$random34][stop]"} ="";

#145
$post_add{"variable[preset][145][$random35]"} ="wday";
$post_add{"variable[preset][145][$random36]"} ="mon";
$post_add{"variable[preset][145][$random37]"} ="mday";
$post_add{"value[145][$random35][start]"} ="2";
$post_add{"value[145][$random35][stop]"} ="";
$post_add{"value[145][$random36][start]"} ="1";
$post_add{"value[145][$random36][stop]"} ="";
$post_add{"value[145][$random37][start]"} ="15";
$post_add{"value[145][$random37][stop]"} ="21";

# &database_clean_string($form{"[1][222][mday]"});

#####
## END
    if ($response{stat} ne 'fail') {
        &post_data (
           'domain_uuid' => $domain{uuid},
           #'urlpath'     => '/app/time_conditions/time_condition_add.php',
		   'urlpath'     => '/app/time_conditions/time_condition_edit.php',
           'reload'      => 0,
           'data'        => [%post_add]);
          
		#$location = $result->header("Location");
        %result = &post_data (
            'domain_uuid' => $domain{uuid},
            'urlpath'     => "/app/dialplan/dialplans.php?app_uuid=4b821450-926b-175a-af93-a03c441818b1",
            'data'        => []
        );
		
		$location = $result->header("Location");
		($uuid) = $location =~ /app_uuid=(.+)$/;
		if (!1) {
			$response{stat}		= "fail";
            $response{message}	= $k. &_(" not valid");
		} else {
			%hash  = &database_select_as_hash("select
										1,dialplan_uuid
									from
										v_dialplans
									where 
										dialplan_name='$post_add{dialplan_name}'",
									'uuid');
									
			$response{stat}		= "ok";
			$response{uuid}=$hash{1}{uuid};
		}       
	}
    &print_json_response(%response);
}


sub gettimeconditionlist () {
	$form{type} = 'time';
    &getdialplanlist();
}

return 1;