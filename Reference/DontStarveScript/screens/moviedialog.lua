local BigPopupDialogScreen = require "screens/bigpopupdialog"

local MovieDialog = Class(BigPopupDialogScreen, function(self, movie_path, callback)
	BigPopupDialogScreen._ctor(self, "MovieDialog", "MovieDialog", 
	{
		{text="Stop Movie", cb = function() TheSim:StopMovie(movie_path) end}
	})
    self.cb = callback
	TheSim:PlayMovie(movie_path)
end)



function MovieDialog:OnUpdate( dt )
	if not TheSim:IsMoviePlaying() then
		TheFrontEnd:PopScreen()
		TheFrontEnd:DoFadeIn(2)
        if self.cb then
            self.cb()
        end
	end
	return true
end

return MovieDialog
