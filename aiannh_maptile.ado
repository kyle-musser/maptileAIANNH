*! 25February2020, Kyle Musser, musser.kyle.j@gmail.com


program define _maptile_aiannh 
	syntax , [  geofolder(string) ///
				mergedatabase ///
				map spmapvar(varname) var(varname) binvar(varname) clopt(string) legopt(string) min(string) clbreaks(string) max(string) mapcolors(string asis) ndfcolor(string) ///
					savegraph(string) replace resolution(string) map_restriction(string) spopt(string) ///
				/* Geography-specific options */ ///
					 stateoutline(string) conus st_fill(string) ///
			 ]
	
	if ("`mergedatabase'"!="") {
		/* XX make sure the geographic ID variable you choose is contained in geoname_database.dta */
		novarabbrev merge 1:m aiannh_id ///
			using `"`geofolder'/aiannh_database.dta"', nogen 
		exit
	}
	
	if ("`map'"!="") {
	
		local conusIFF "" // blank IFF if no mapsub selected
		
	
		if ("`conus'"=="conus") {
			* Hide AK and HI from stateoutline
			local polygon_select select(drop if inlist(_ID,27,8))
				
			* Hide AK and HI from main map
			*Get AIANNH ID's that are in AK to drop.
			# delimit ;
			local conusIFF "if !inlist(aiannh_id,  110, 6015, 6020, 6025, 6030, 6035,
				6040, 6045, 6065, 6070, 6075, 6080, 6095, 6100, 6105, 6125, 6140, 6150,
				6160, 6165, 6175, 6190, 6195, 6205, 6225, 6235, 6240, 6250,
                6255, 6257, 6265, 6275, 6280, 6285, 6290, 6295, 6300, 6305, 6310, 6315,
				6325, 6330, 6335, 6340, 6350, 6360, 6365, 6380, 6385, 6390, 6400, 6405,
				6415, 6420, 6430, 6440,
                6445, 6450, 6455, 6460, 6470, 6480, 6490, 6495, 6500, 6515, 6520, 6525,
				6530, 6535, 6540, 6545, 6550, 6560, 6570, 6575, 6585, 6590, 6595, 6605,
				6610, 6615, 6620, 6625,
                6630, 6650, 6670, 6680, 6685, 6690, 6700, 6705, 6710, 6720, 6725, 6730,
				6735, 6740, 6750, 6755, 6765, 6785, 6790, 6795, 6800, 6810, 6815, 6820,
				6825, 6830, 6835, 6840,
                6845, 6850, 6855, 6860, 6865, 6875, 6890, 6895, 6900, 6905, 6910, 6915,
				6935, 6945, 6965, 6975, 6990, 6995, 7005, 7010, 7020, 7025, 7030, 7035,
				7040, 7050, 7055, 7065,
                7070, 7075, 7080, 7085, 7095, 7100, 7110, 7115, 7125, 7130, 7133, 7135,
				7145, 7150, 7175, 7180, 7185, 7205, 7215, 7220, 7225, 7230, 7235, 7245,
				7250, 7255, 7260, 7263,
                7265, 7270, 7275, 7300, 7305, 7310, 7315, 7340, 7375, 7390, 7400, 7410,
				7415, 7420, 7425, 7430, 7435, 7440, 7450, 7465, 7470, 7475, 7485, 7495,
				7500, 7505, 7510, 7520,
                7525, 7530, 7535, 7540, 7555, 7560, 7565, 7570, 7580, 7605, 7625, 7630,
				7640, 7645, 7650, 7655, 7665, 7690, 7695, 7725, 7735, 7740, 7745, 7755, 7765
				)"
			;
			# delimit cr
			
		}

		if ("`stateoutline'"!="") {
			cap confirm file `"`geofolder'/state_coords_clean.dta"'
			if (_rc==0) local polygon polygon(data(`"`geofolder'/state_coords_clean"') ocolor(black) fcolor(`st_fill') osize(`stateoutline' ...) `polygon_select')
			else if (_rc==601) {
				di as error `"stateoutline() requires the {it:state} geography to be installed"'
				di as error `"--> state_coords_clean.dta must be present in the geofolder"'
				exit 198				
			}
			else {
				error _rc
				exit _rc
			}
		}
		
		
		*Map... need the delimit for the conusIFF
		# delimit ;
		spmap `spmapvar' using `"`geofolder'/aiannh_coords.dta"' `conusIFF', id(_ID) 
			`clopt'
			`legopt' 
			legend(pos(5) size(*1.8)) 
			fcolor(`mapcolors') ndfcolor(`ndfcolor') 
			oc(black ...) ndo(black) 
			os(vthin ...) nds(vthin) 
			`polygon' 
			`spopt'
		;
		# delimit cr
		
		* Save graph
		if (`"`savegraph'"'!="") __savegraph_maptile, savegraph(`savegraph') resolution(`resolution') `replace'
		
	}
	
end program

* Save map to file
cap program drop __savegraph_maptile
program define __savegraph_maptile

	syntax, savegraph(string) resolution(string) [replace]
	
	* check file extension using a regular expression
	if regexm(`"`savegraph'"',"\.[a-zA-Z0-9]+$") local graphextension=regexs(0)
	
	* deal with different filetypes appropriately
	if inlist(`"`graphextension'"',".gph","") graph save `"`savegraph'"', `replace'
	else if inlist(`"`graphextension'"',".ps",".eps") graph export `"`savegraph'"', mag(`=round(100*`resolution')') `replace'
	else if (`"`graphextension'"'==".png") graph export `"`savegraph'"', width(`=round(3200*`resolution')') `replace'
	else if (`"`graphextension'"'==".tif") graph export `"`savegraph'"', width(`=round(1600*`resolution')') `replace'
	else graph export `"`savegraph'"', `replace'

end

