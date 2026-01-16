-- cycle through all of the songs in this folder

local folder = game.SoundService.Music
local songs = folder:GetChildren()

while true do
	--can you make it start at a random song?/
	for i = 1, math.random(1,#songs) do
		local song = songs[i]
		song:Play()
		song.Ended:Wait()
	end

end