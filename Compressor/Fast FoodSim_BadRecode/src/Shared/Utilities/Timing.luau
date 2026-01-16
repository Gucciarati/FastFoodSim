-- Timing functions
-- You pass duration (and perhaps some extra info based on the function), and
-- you get back a function that you call with time to get an alpha value 0..1

local Timing = {}
local sqrt = math.sqrt
local sin = math.sin
local cos = math.cos
local pi = math.pi

Timing.linear = function(d)
	return function(t)
		return t/d
	end
end

--Timing.ease = {}
--Timing.ease.In = {}
--Timing.ease.Out = {}
--Timing.ease.InOut = {}

Timing.easeInQuad = function(d)
	return function(t)
		return (t/d)^2
	end
end

Timing.easeOutQuad = function(d)
	return function(t)
		t = t / d
		return -t * (t-2)
	end
end

Timing.easeInOutQuad = function(d)
	return function(t)
		t = t * 2 / d
		if t < 1 then
			return 0.5*t^2
		end
		t = t - 1
		return -0.5 * (t*(t-2) - 1)
	end
end

Timing.easeInCubic = function(d)
	return function(t)
		return (t/d)^3
	end
end

Timing.easeOutCubic = function(d)
	return function(t)
		t = t / d - 1
		return t*t*t + 1
	end
end

Timing.easeInOutCubic = function(d)
	return function(t)
		t = t * 2 / d
		if t < 1 then
			return 0.5 * t^3
		end
		t = t - 2
		return 0.5*(t^3 + 2)
	end
end

Timing.easeInQuart = function(d)
	return function(t)
		return (t/d)^4
	end
end

Timing.easeOutQuart = function(d)
	return function(t)
		t = t / d - 1
		return -(t^4 - 1)
	end
end

Timing.easeInOutQuart = function(d)
	return function(t)
		t = t * 2 / d
		if t < 1 then
			return 0.5*t^4
		end
		t = t - 2
		return -0.5 * (t^4 - 2)
	end
end

Timing.easeInQuint = function(d)
	return function(t)
		return (t/d)^5
	end
end

Timing.easeOutQuint = function(d)
	return function(t)
		t = t / d - 1
		return t^5 + 1
	end
end

Timing.easeInOutQuint = function(d)
	return function(t)
		t = t * 2 / d
		if t < 1 then
			return 0.5*t^5
		end
		t = t - 2
		return 0.5*(t^5 + 2)
	end
end

Timing.easeInSine = function(d)
	return function(t)
		return -cos(t/d * pi/2) + 1
	end
end

Timing.easeOutSine = function(d)
	return function(t)
		return sin(t/d * pi/2)
	end
end

Timing.easeInOutSine = function(d)
	return function(t)
		return -0.5 * (cos(pi*t/d) - 1)
	end
end

Timing.easeInExpo = function(d)
	return function(t)
		return 2^(10 * (t/d - 1))
	end
end

Timing.easeOutExpo = function(d)
	return function(t)
		return -(2^(-10 * t/d)) + 1
	end
end

Timing.easeInOutExpo = function(d)
	return function(t)
		t = t * 2 / d
		if t < 1 then
			return 0.5 * 2^(10 * (t - 1))
		end
		t = t - 1
		return 0.5 * (-(2^(-10 * t)) + 2)
	end
end

Timing.easeInCirc = function(d)
	return function(t)
		return -(sqrt(1 - (t/d)^2) - 1)
	end
end

Timing.easeOutCirc = function(d)
	return function(t)
		t = t / d - 1
		return sqrt(1 - t^2)
	end
end

Timing.easeInOutCirc = function(d)
	return function(t)
		t = t * 2 / d
		if t < 1 then
			return -0.5 * (sqrt(1 - t^2) - 1)
		end
		t = t - 2
		return 0.5 * (sqrt(1 - t^2) + 1)
	end
end

Timing.sineBack = function(d)
	return function(t)
		return sin(t/d*pi)
	end
end


Timing.easeInBack = function(d, s)
	s = s or 1.70158
	return function(t)
		t = t / d
		return t*t*((s+1)*t - s)
	end
end



Timing.cubicBezier = function(d, p1x, p1y, p2x, p2y)
	-- defaults to an inefficient linear
	p1x = p1x or 0
	p1y = p1y or 0
	p2x = p2x or 1
	p2y = p2y or 1
	
	local cx = 3*p1x
	local bx = 3*(p2x-p1x)-cx
	local ax = 1-cx-bx
	local cy = 3*p1y
	local by = 3*(p2y-p1y)-cy
	local ay = 1-cy-by
	
	local epsilon = 1/(200*d)
	
	local function sampleCurveX(t)
		return ((ax*t+bx)*t+cx)*t
	end
	local function sampleCurveY(t)
		return ((ay*t+by)*t+cy)*t
	end
	local function sampleCurveDerivativeX(t)
		return (3*ax*t+2*bx)*t+cx
	end
	local function solveCurveX(x)
		local t0, t1, t2, x2, d2, i
		local function fabs(n)
			return n >= 0 and n or 0-n
		end
		t2 = x
		for i = 0, 7 do
			x2 = sampleCurveX(t2)-x
			if fabs(x2) < epsilon then
				return t2
			end
			d2 = sampleCurveDerivativeX(t2)
			if fabs(d2) < 1e-6 then
				break
			end
			t2 = t2-x2/d2
		end
		t0 = 0
		t1 = 1
		t2 = x
		if t2 < t0 then
			return t0
		elseif t2 > t1 then
			return t1
		end
		while t0 < t1 do
			x2 = sampleCurveX(t2)
			if fabs(x2-x) < epsilon then
				return t2
			elseif x > x2 then
				t0 = t2
			else
				t1=t2
			end
			t2 = (t1-t0)*0.5+t0
		end
        return t2
    end
	
	return function(t)
		return sampleCurveY(solveCurveX(t/d))
	end
end


--[[ also found these gems
	where:
		x -> ignore
		c -> treat as 1 (equals the goal change, and we always go from 0 to 1)
		b -> treat as 0 (equals the starting value, and again, we go from 0 to 1)
		t -> elapsed time
		d -> total duration
	
	def: 'easeOutQuad',
	swing: function (x, t, b, c, d) {
		//alert(jQuery.easing.default);
		return jQuery.easing[jQuery.easing.def](x, t, b, c, d);
	},
	easeInQuad: function (x, t, b, c, d) {
		return c*(t/=d)*t + b;
	},
	easeOutQuad: function (x, t, b, c, d) {
		return -c *(t/=d)*(t-2) + b;
	},
	easeInOutQuad: function (x, t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t + b;
		return -c/2 * ((--t)*(t-2) - 1) + b;
	},
	easeInCubic: function (x, t, b, c, d) {
		return c*(t/=d)*t*t + b;
	},
	easeOutCubic: function (x, t, b, c, d) {
		return c*((t=t/d-1)*t*t + 1) + b;
	},
	easeInOutCubic: function (x, t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t*t + b;
		return c/2*((t-=2)*t*t + 2) + b;
	},
	easeInQuart: function (x, t, b, c, d) {
		return c*(t/=d)*t*t*t + b;
	},
	easeOutQuart: function (x, t, b, c, d) {
		return -c * ((t=t/d-1)*t*t*t - 1) + b;
	},
	easeInOutQuart: function (x, t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t*t*t + b;
		return -c/2 * ((t-=2)*t*t*t - 2) + b;
	},
	easeInQuint: function (x, t, b, c, d) {
		return c*(t/=d)*t*t*t*t + b;
	},
	easeOutQuint: function (x, t, b, c, d) {
		return c*((t=t/d-1)*t*t*t*t + 1) + b;
	},
	easeInOutQuint: function (x, t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t*t*t*t + b;
		return c/2*((t-=2)*t*t*t*t + 2) + b;
	},
	easeInSine: function (x, t, b, c, d) {
		return -c * Math.cos(t/d * (Math.PI/2)) + c + b;
	},
	easeOutSine: function (x, t, b, c, d) {
		return c * Math.sin(t/d * (Math.PI/2)) + b;
	},
	easeInOutSine: function (x, t, b, c, d) {
		return -c/2 * (Math.cos(Math.PI*t/d) - 1) + b;
	},
	easeInExpo: function (x, t, b, c, d) {
		return (t==0) ? b : c * Math.pow(2, 10 * (t/d - 1)) + b;
	},
	easeOutExpo: function (x, t, b, c, d) {
		return (t==d) ? b+c : c * (-Math.pow(2, -10 * t/d) + 1) + b;
	},
	easeInOutExpo: function (x, t, b, c, d) {
		if (t==0) return b;
		if (t==d) return b+c;
		if ((t/=d/2) < 1) return c/2 * Math.pow(2, 10 * (t - 1)) + b;
		return c/2 * (-Math.pow(2, -10 * --t) + 2) + b;
	},
	easeInCirc: function (x, t, b, c, d) {
		return -c * (Math.sqrt(1 - (t/=d)*t) - 1) + b;
	},
	easeOutCirc: function (x, t, b, c, d) {
		return c * Math.sqrt(1 - (t=t/d-1)*t) + b;
	},
	easeInOutCirc: function (x, t, b, c, d) {
		if ((t/=d/2) < 1) return -c/2 * (Math.sqrt(1 - t*t) - 1) + b;
		return c/2 * (Math.sqrt(1 - (t-=2)*t) + 1) + b;
	},
	easeInElastic: function (x, t, b, c, d) {
		var s=1.70158;var p=0;var a=c;
		if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;
		if (a < Math.abs(c)) { a=c; var s=p/4; }
		else var s = p/(2*Math.PI) * Math.asin (c/a);
		return -(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
	},
	easeOutElastic: function (x, t, b, c, d) {
		var s=1.70158;var p=0;var a=c;
		if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;
		if (a < Math.abs(c)) { a=c; var s=p/4; }
		else var s = p/(2*Math.PI) * Math.asin (c/a);
		return a*Math.pow(2,-10*t) * Math.sin( (t*d-s)*(2*Math.PI)/p ) + c + b;
	},
	easeInOutElastic: function (x, t, b, c, d) {
		var s=1.70158;var p=0;var a=c;
		if (t==0) return b;  if ((t/=d/2)==2) return b+c;  if (!p) p=d*(.3*1.5);
		if (a < Math.abs(c)) { a=c; var s=p/4; }
		else var s = p/(2*Math.PI) * Math.asin (c/a);
		if (t < 1) return -.5*(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
		return a*Math.pow(2,-10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )*.5 + c + b;
	},
	easeInBack: function (x, t, b, c, d, s) {
		if (s == undefined) s = 1.70158;
		return c*(t/=d)*t*((s+1)*t - s) + b;
	},
	easeOutBack: function (x, t, b, c, d, s) {
		if (s == undefined) s = 1.70158;
		return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
	},
	easeInOutBack: function (x, t, b, c, d, s) {
		if (s == undefined) s = 1.70158; 
		if ((t/=d/2) < 1) return c/2*(t*t*(((s*=(1.525))+1)*t - s)) + b;
		return c/2*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b;
	},
	easeInBounce: function (x, t, b, c, d) {
		return c - jQuery.easing.easeOutBounce (x, d-t, 0, c, d) + b;
	},
	easeOutBounce: function (x, t, b, c, d) {
		if ((t/=d) < (1/2.75)) {
			return c*(7.5625*t*t) + b;
		} else if (t < (2/2.75)) {
			return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
		} else if (t < (2.5/2.75)) {
			return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
		} else {
			return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
		}
	},
	easeInOutBounce: function (x, t, b, c, d) {
		if (t < d/2) return jQuery.easing.easeInBounce (x, t*2, 0, c, d) * .5 + b;
		return jQuery.easing.easeOutBounce (x, t*2-d, 0, c, d) * .5 + c*.5 + b;
	}
});
--]]

return Timing

