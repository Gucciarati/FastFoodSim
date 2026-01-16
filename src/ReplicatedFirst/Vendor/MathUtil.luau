local MathUtil = {}


function MathUtil.ScaleGuiToResolution(guiObject: GuiBase)
	local function ScaleUIProperty(initialValue: number, targetResolution: number?, fromResolution: number?)
		targetResolution = targetResolution or workspace.Camera.ViewportSize.X
		fromResolution   = fromResolution or 854 -- Iphone 14 portrait resolution in px
		assert(fromResolution and targetResolution)
		return initialValue * targetResolution/fromResolution
	end


	for _, child in guiObject:GetDescendants() do
		if child:IsA("UIStroke") then
			local initial = child.Thickness 
			local scaled = ScaleUIProperty(initial)
			child.Thickness = scaled
		end

		if child:IsA("UITextSizeConstraint") then
			local initial = child.MaxTextSize 
			local scaled = ScaleUIProperty(initial)
			child.MaxTextSize = scaled
		end

		if child:IsA('ScrollingFrame') then
			local initial = child.ScrollBarThickness
			local scaled = ScaleUIProperty(initial)
			child.ScrollBarThickness = scaled
		end		
	end
end


--[=[
    This is a known as a linear indexing function which allow us to refer to the
    elements of a matrix with a single array
    
    A = [2 6 9; 4 2 8; 3 5 1]
    A =
        2     6     9
        4     2     8
        3     5     1

    matlab link: http://matlab.izmiran.ru/help/techdoc/matlab_prog/ch10_pr9.html

    Stupidly useful when working with matrixes or when you need to map an array
    to a matrix/tensor.
]=]
function MathUtil.TranslateLinearIndex(index, maxSize): (number, number)
	local row = math.floor((index - 1) / maxSize) + 1
	local column = (index - 1) % maxSize + 1
	return row, column
end


return MathUtil