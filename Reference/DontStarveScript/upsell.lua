local upsell_status = nil
local waitingforpurchasetimeout = 0

DEMO_QUITTING = false

function IsGamePurchased()
	local purchased = Purchases ~= nil and table.contains( Purchases, "GAME" )
	return purchased
end

function UpdateGamePurchasedState( complete_callback )
	--print( "UpdateGamePurchaseState called" )
	if PLATFORM == "NACL" then
		TheSim:QueryServer( GAME_SERVER.."/user/purchases",
			function( result, isSuccessful, resultCode )
				print( "UpdateGamePurchaseState callback", result, isSuccessful, resultCode )
			 	if isSuccessful and string.len(result) > 1 then 
					Purchases = TrackedAssert("TheSim:QueryServer /user/purchases", json.decode, result)
				end
				if( complete_callback ) then
					complete_callback( IsGamePurchased() )
				end
			end,
			"GET" )
	else
		if( complete_callback ) then
			complete_callback( IsGamePurchased() )
		end
	end
end



function UpsellShowing()
	return upsell_status == "SHOWING"
end

function WaitingForPurchaseState()
	return upsell_status == "WAITING"
end


function ShowUpsellScreen(shouldquit)
	if not upsell_status then
		--print ("ShowUpsellScreen")
		upsell_status = "SHOWING"
		local trigger = json.encode{upsell={timedout=shouldquit}}
		TheSim:SendUITrigger(trigger)
		SetPause(true,"upsell")
	end
end


function CheckForUpsellTimeout(dt)
	if WaitingForPurchaseState() then
		waitingforpurchasetimeout = waitingforpurchasetimeout + dt
		if waitingforpurchasetimeout > 30 then
			--print ("Upsell callback timed out. Very odd.")
			SetPause(false)
    		
			local player = GetPlayer()
    		if player then
    			player:PushEvent("quit", {})
    		end
    		upsell_status = "QUITTING"    		
    		waitingforpurchasetimeout = 0
		end
	end
end


function CheckDemoTimeout()
	if not UpsellShowing() and not IsGamePurchased() and GetTimePlaying() > TUNING.DEMO_TIME then
		if not DEMO_QUITTING then
			--print ("DEMO TIME OUT! Show the upsell screen")
			ShowUpsellScreen(true)
		end
	end
end

function HandleUpsellClose()
	--print("HandleUpsellClose")
	upsell_status = "WAITING"
   
	UpdateGamePurchasedState( 
		function(is_purchased) 
			local active_screen = TheFrontEnd:GetActiveScreen()
			if active_screen and active_screen.Refresh then
				active_screen:Refresh()
			end

			upsell_status = nil
			SetPause(false)

			if DEMO_QUITTING or ( not is_purchased and GetTimePlaying() > TUNING.DEMO_TIME ) then
				local player = GetPlayer()
   				if player then
					DEMO_QUITTING = true
   					player:PushEvent("quit", {})
   				end
   			end
   		end)
end    


