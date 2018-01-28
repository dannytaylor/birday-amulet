-- happy birday

local win = am.window{
    title = "it's ya birday",
    width = 960,
    height = 540,
    clear_color = vec4(1,1,1,1),
}

lock = false
locktime = 3
hover = false
opened = false


x = -256
y = -32
sanic =	am.translate(x,y) ^ am.scale(vec2(1,1)) ^ am.sprite("img/i.png")
vx = 150 -- movement speed
sx = 1 -- sprite flip
ox = 24 -- deadband for movement
state = "i"
sanic.position2d = vec2(x+sx*20,y)

cx = 256
chest =	am.translate(cx,y) ^ am.scale(1) ^ am.sprite("img/c.png")
message = am.translate(0,0).am.sprite("yeah.png")
message.hidden = true
prompt = am.translate(96,160) ^ am.sprite("prompt.png")
prompt.hidden = true

part = am.particles2d{
	source_pos = vec2(0,360),
	source_pos_var = vec2(16),
	start_size = 64,
	max_particles = 100,
	life = 24,
	angle = 1.5*math.pi,
	angle_var = 0.4*math.pi,
	speed = 32,
	speed_var = 5,
	emission_rate = 0.7,
	start_particles = 1,

	gravity = vec2(0,-2),
	sprite_source = "dog.png",
}
part1=am.particles2d{
    source_pos = vec2(-300,-420),
    source_pos_var = vec2(20),
    max_particles = 1000,
    emission_rate = 4,
    start_particles = 0,
    life = 7,
    life_var = 0.2,
    angle = math.rad(90),
    angle_var = math.rad(180),
    speed = 40,
    start_color = vec4(1, 0.3, 0.03, 0.5),
    start_color_var = vec4(0.3, 0.2, 0.2, 0.2),
    end_color = vec4(1, 1, 1, 1),
    end_color_var = vec4(0.1),
    start_size = 30,
    start_size_var = 10,
    end_size = 2,
    end_size_var = 2,
    gravity = vec2(0, 30),
}
part2=am.particles2d{
    source_pos = vec2(300,-420),
    source_pos_var = vec2(20),
    max_particles = 1000,
    emission_rate = 4,
    start_particles = 0,
    life = 8,
    life_var = 0.2,
    angle = math.rad(90),
    angle_var = math.rad(180),
    speed = 40,
    start_color = vec4(0.1, 0.2, 0.9, 0.5),
    start_color_var = vec4(0.2, 0.2, 0.3, 0.2),
    end_color = vec4(1, 1, 1, 1),
    end_color_var = vec4(0.1),
    start_size = 30,
    start_size_var = 10,
    end_size = 2,
    end_size_var = 2,
    gravity = vec2(0, 30),
}

part.hidden,part1.hidden,part2.hidden = true,true,true

sanic:action(function()
	local dt = am.delta_time

	-- movement
		state="i"
		if win:mouse_down"left" and not lock then
			local mx = win:mouse_position().x
			if x < mx - ox and x < 408 then -- move right
				x = x + vx*dt
				sx = 1
				state = "w"
			elseif x > mx + ox and x > -408 then -- move left
				x = x - vx*dt
				sx = -1
				state = "w"
			else
				state = "i"
			end
			sanic.position2d = vec2(x+sx*20,y)
			sanic"scale".x = sx
		elseif lock then
			locktime = locktime - dt
			state = "o"
			if locktime < 1 then
				state = "h"
				if locktime<0 then
					lock = false
				end
			end
		end

	-- chest
		-- if on top of chest
		if not opened then
			if x < cx + 100 and x > cx - 100 then
				hover = true
				if win:mouse_down"right" then
					-- local mx = win:mouse_position().x
					-- local my = win:mouse_position().y
					-- if mx < 100 and mx > -100 and my > -200 and my < -100 then
					if x < cx + 8 then
						sanic"scale".x = 1
					elseif x > cx + 8 then
						sanic"scale".x = -1
					end
					opened = true
					part"particles2d".reset()
					part1"particles2d".reset()
					part2"particles2d".reset()
					part.hidden,part1.hidden,part2.hidden = false,false,false
					chest"sprite".source = "img/c_open.png"
					lock = true

					state = "o"
					-- end
				end
			else
				hover = false
			end
		end
	-- anim
		local frame = math.floor(am.current_time()*2)%2
		if state == "i" or state == "h" then
			frame = ""
		end
		sanic"sprite".source = "img/"..state..frame..".png"

	-- sprite hiding
		if hover and not opened then
			prompt.hidden = false
		else
			prompt.hidden = true
		end
		if opened and not lock or state == "h" then
			message.hidden = false
		end



end)


win.scene =
    am.group()
    ^ {
    	part,
    	part1,
    	part2,
    	chest,
    	message,
    	sanic,
    	prompt,
    }

win.scene:action(function(scene)
    if win:key_down"q" then
		win:close()
	end

end)

win.scene:action(am.play("song.ogg",true,1,0.25))