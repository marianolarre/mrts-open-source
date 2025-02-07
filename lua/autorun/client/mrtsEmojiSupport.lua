if SERVER then return end
local EmojiMaterials = {}
local ErrorMaterial = Material("icon16/picture_error.png")
local LoadingMaterial = Material("icon16/hourglass.png")
function GetEmojiMaterialFromCode(emojiCode)
	local url = "https://raw.githubusercontent.com/twitter/twemoji/master/assets/72x72/"..emojiCode..".png"
	if EmojiMaterials[emojiCode] then
		-- Material already cached
		return EmojiMaterials[emojiCode]
	end 
	EmojiMaterials[emojiCode] = LoadingMaterial
	if (file.Exists("mrts/temp/img/"..emojiCode..".png", "DATA")) then
		-- Cache already downloaded image
		EmojiMaterials[emojiCode] = Material("../data/mrts/temp/img/"..emojiCode..".png")
		return EmojiMaterials[emojiCode]
	else
		http.Fetch( url,
			-- onSuccess
			function( body, length, headers, code )
				-- Download image and store it in cache
				file.CreateDir("mrts/temp/img")
				file.Write("mrts/temp/img/"..emojiCode..".png", body)
				EmojiMaterials[emojiCode] = Material("../data/mrts/temp/img/"..emojiCode..".png")
				print("Downloaded image: "..emojiCode)
			end,
			-- onFailure
			function( message )
				print( "Couldnt load image from code "..emojiCode )
			end
		)
		return LoadingMaterial
	end
end

function GetEmojiMaterial(emoji)
	local components = {}
	for k, v in utf8.codes(emoji) do
		table.insert(components, string.TrimLeft(bit.tohex(v), "0"))
	end
	local emojiCode = table.concat(components, "-")
	return GetEmojiMaterialFromCode(emojiCode)
end

function DrawEmoji(emoji, x, y, size, black)
	surface.SetMaterial(GetEmojiMaterial(emoji))
	if (black) then
		surface.SetDrawColor(0,0,0,255)
	else
		surface.SetDrawColor( 255, 255, 255, 255 )
	end
	surface.DrawTexturedRect(x-size/2,y-size/2,size,size)
end