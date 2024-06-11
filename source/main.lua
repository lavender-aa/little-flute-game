import "CoreLibs/object"
import "CoreLibs/graphics"

local pd <const> = playdate
local gfx <const> = pd.graphics

local curr_note = {degree=0, pitch=0}
local synthPlayer = pd.sound.synth.new()

local degree_center = {x=130, y=120}
local pitch_center = {x=275, y=120}

function pd.update()
	gfx.clear()

	-- draw directions to show degree and pitch
	local width, height = 100, 15
	gfx.fillRect(degree_center.x - width/2, degree_center.y - height/2, width, height)
	width, height = height, width
	gfx.fillRect(degree_center.x - width/2, degree_center.y - height/2, width, height)
	gfx.setLineWidth(3)
	gfx.drawLine(pitch_center.x - 25, pitch_center.y, pitch_center.x + 25, pitch_center.y)

	-- assign input from user to create the pitch
	curr_note = getNoteFromInput()

	-- visually show the note
	drawDegree(curr_note, degree_center)
	drawPitch(curr_note, pitch_center)

	-- play the note
	playNote(curr_note)
end

-- returns a table containing a degree and a pitch
-- (degree and pitch nil if no buttons are pressed)
function getNoteFromInput()
	local deg, pit = 0, 0

	-- shorthands
	local pressed = pd.buttonIsPressed
	local buttons = {
		pd.kButtonRight,
		pd.kButtonDown,
		pd.kButtonLeft,
		pd.kButtonUp
	}

	-- table to keep track of what directional buttons
	-- are currently being pressed ('1111' -> 'rdlu')
	local dir = ""
	for _, b in ipairs(buttons) do dir = dir .. (pressed(b) and "1" or "0") end

	-- figure out what pitch to play
	pit = 0
	if pressed(pd.kButtonA) then pit += 1 end
	if pressed(pd.kButtonB) then pit -= 1 end

	-- check if no buttons are being pressed;
	-- turn off the tone and return early 
	-- (cannot press two opposite directions at once physically)
	if synthPlayer == nil then return {digree=0, pitch=pit} end
	if dir == '0000' then synthPlayer:noteOff() ; return {degree=0, pitch=pit} end

	-- set the degree number based on what buttons are pressed
	-- (haha pears get it? like pairs)
	local pears = {'1000', '1100', '0100', '0110', '0010', '0011', '0001', '1001'}
	for a, b in ipairs(pears) do
		if dir == b then deg = a end
	end

	-- return the table with these two pieces of information
	return {degree=deg, pitch=pit}
end

function drawDegree(note, degree_center)

	-- draw the degree of the note 
	local x, y = degree_center.x, degree_center.y
	local radius = 75
	if note == nil or note.degree == nil or note.degree == 0 then return
	else 
		-- degree=1 starts to the right, then moving by an 8th
		-- of a revolution around the circle for each next degree
		-- (see https://www.desmos.com/calculator/9qygmub9fr for an interactive display)
		local angle = (-2 * math.pi * (note.degree - 1)) / 8
		x, y = x + radius * math.cos(angle), y - radius * math.sin(angle) -- have to invert y direction because down increases y value
		
		-- draw the circle
		gfx.fillCircleAtPoint(x, y, 10)
	end
end

function drawPitch(note, pitch_center) 
	-- find the coordinates where the pitch visual should be
	local x, y = pitch_center.x, pitch_center.y

	if note.pitch == nil then return end
	y = pitch_center.y - 20 * note.pitch

	-- draw the pitch
	gfx.fillCircleAtPoint(x, y, 10)
end

function playNote(note)
	local text = ""
	if note.degree == 0 then return end

	-- add the correct note modifier
	if note.pitch == 1 then text = text .. "#"
	elseif note.pitch == -1 then text = text .. "b"
	end

	-- add the correct note base and octave
	local notes = {'C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4', 'C5'}
	text = notes[note.degree]:sub(1, 1) .. text .. notes[note.degree]:sub(2,2)

	if synthPlayer == nil then return end
	synthPlayer:playMIDINote(text)
end