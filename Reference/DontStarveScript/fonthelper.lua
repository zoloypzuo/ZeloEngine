function AddFontAssets( asset_table, font_table )
	for i, fontdata in ipairs( font_table ) do
		table.insert( asset_table, Asset( "FONT", fontdata.filename ) )
	end
end
