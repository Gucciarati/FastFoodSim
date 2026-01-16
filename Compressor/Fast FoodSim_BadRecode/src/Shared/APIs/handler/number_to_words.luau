local module = {}
local numbers = {
	[0] = "Zero",
	[1] = "One",
	[2] = "Two",
	[3] = "Three",
	[4] = "Four",
	[5] = "Five",
	[6] = "Six",
	[7] = "Seven",
	[8] = "Eight",
	[9] = "Nine",
	[10] = "Ten",
	[11] = "Eleven",
	[12] = "Twelve",
	[13] = "Thirteen",
	[14] = "Fourteen",
	[15] = "Fifteen",
	[16] = "Sixteen",
	[17] = "Seventeen",
	[18] = "Eighteen",
	[19] = "Nineteen",
	
	[20] = "Twenty",
	[30] = "Thirty",
	[40] = "Forty",
	[50] = "Fifty",
	[60] = "Sixty",
	[70] = "Seventy",
	[80] = "Eighty",
	[90] = "Ninety",
	
	[100] = "Hundred",
	[1000^1] = "Thousand",
	[1000^2] = "Million",
	[1000^3] = "Billion",
	[1000^4] = "Trillion",
	[1000^5] = "Quadrillion",
	[1000^6] = "Quintillion",
	[1000^7] = "Sextillion",
	[1000^8] = "Septillion",
	[1000^9] = "Octillion",
	[1000^10] = "Nonillion",
	[1000^11] = "Decillion",
	[1000^12] = "Undecillion",
	[1000^13] = "Duodecillion",
	[1000^14] = "Tredecillion",
	[1000^15] = "Quattuordecillion",
	[1000^16] = "Quindecillion",
	[1000^17] = "Sexdecillion",
	[1000^18] = "Septendecillion",
	[1000^19] = "Octodecillion",
	[1000^20] = "Novemdecillion",
	[1000^21] = "Vigintillion",
	[1000^101] = "Centillion",
	[math.huge] = "Infinity",
}

function module.convert(number, previous)
	if not number or type(number) ~= "number" then return 0 end
	if numbers[number] and number < 100 then
		return numbers[number]
	elseif number >= math.huge then
		return numbers[math.huge]
	else
		local highestNum = 0
		for num,text in pairs(numbers) do
			if highestNum >= num or num > number then continue end
			highestNum = num
		end
		local amount = math.floor(number/highestNum)
		local remaining = number-amount*highestNum
		local str = numbers[highestNum]
		if highestNum > 99 then
			str = module.convert(amount, highestNum).." "..str
		end
		if remaining > 0 then
			local dash = highestNum < 100 and "-" or " "
			str = str..dash..module.convert(remaining, highestNum)
		end
		return str
	end
end

return module