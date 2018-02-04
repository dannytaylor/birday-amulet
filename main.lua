-- happy birday
math.randomseed(os.time())
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
spawn_dog = -1
if am.platform == "html" then
	html = true
else
	html = false
end
html= true
x = -256
y = -32
sanic =	am.translate(x,y) ^ am.scale(vec2(1,1)) ^ am.sprite("img/i.png")
vx = 150 -- movement speed
sx = 1 -- sprite flip
ox = 24 -- deadband for movement
state = "i"
sanic.position2d = vec2(x+sx*20,y)

cx = 256
ty = -194
tx = 0
chest =	am.translate(cx,y) ^ am.scale(1) ^ am.sprite("img/c.png")
touch =	am.translate(tx,ty) ^ am.sprite("img/x.png")
message = am.translate(0,0).am.sprite("img/yeah.png")
message.hidden = true
prompt = am.translate(96,160) ^ am.sprite("img/prompt.png")
prompt.hidden = true

chomp = am.load_audio("img/chomp.ogg")

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


part1.hidden,part2.hidden = true,true

sanic:action(function()
	local dt = am.delta_time
	local mx = win:mouse_position().x
	local my = win:mouse_position().y
	-- movement
		state="i"
		if win:mouse_down"left" and not lock then
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
				local ttest = false
				if html and mx>tx-40 and mx<tx+40 and my>ty-40 and my<ty+40 and win:mouse_pressed"left" then
					ttest = true
				else
					ttest = false
				end
				if win:mouse_down"right" or ttest then
					-- local mx = win:mouse_position().x
					-- local my = win:mouse_position().y
					-- if mx < 100 and mx > -100 and my > -200 and my < -100 then
					if x < cx + 8 then
						sanic"scale".x = 1
					elseif x > cx + 8 then
						sanic"scale".x = -1
					end
					opened = true
					part1"particles2d".reset()
					part2"particles2d".reset()
					part1.hidden,part2.hidden = false,false
					chest"sprite".source = "img/c_open.png"
					lock = true

					state = "o"
					-- end
				end
			else
				hover = false
			end
		end

	-- cdog particles
	if opened then
		spawn_dog = spawn_dog + dt
		if spawn_dog > 1.3 then
			spawn_cdog()
			spawn_dog = 0
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
			-- prompt.hidden = false
			if html then
				touch.hidden = false
			end
		else
			prompt.hidden = true
			touch.hidden = true
		end
		if opened and not lock or state == "h" then
			message.hidden = false
		end



end)

dog_group = am.group()

win.scene =
    am.group()
    ^ {
    	part1,
    	part2,
    	chest,
    	message,
    	dog_group,
    	sanic,
    	prompt,
    	touch,
    }

num_dogs = 0
start_dog = 0
c_angle = {}
function spawn_cdog()
	local cdog = 
		am.translate(math.random(-440,440),320):tag("t" .. tostring(num_dogs+start_dog))
		^ am.rotate(0):tag("r" .. tostring(num_dogs+start_dog))
			^ am.sprite("img/dog.png")
    c_angle[num_dogs+start_dog] = math.random(0.8,1.8)
	if num_dogs < 10 then
		num_dogs = num_dogs + 1
	else
		start_dog = start_dog + 1
		dog_group:remove(dog_group:child(1))
	end
	dog_group:append(cdog)			
end

cdog_angle = 0
win.scene:action(function(scene)
	local dt = am.delta_time
    if win:key_down"q" then
		win:close()
	end

	
	for i=start_dog,num_dogs+start_dog do
		if 	dog_group("t" .. tostring(i)) then
			dog_group("r" .. tostring(i)).angle = dog_group("r" .. tostring(i)).angle + c_angle[i]*dt
			local dogv = dog_group("t" .. tostring(i)).position2d
			local dy = dogv.y - 100*dt
			local dx = dogv.x
			dog_group("t" .. tostring(i)).position2d = vec2(dx,dy)

			if win:mouse_pressed"left" then
				local mx = win:mouse_position().x
				local my = win:mouse_position().y
				local box = 48
				if mx > dx-box and mx<dx+box and my>dy-box and my<dy+box and not dog_group("t" .. tostring(i)).hidden then
					dog_group("t" .. tostring(i)).hidden = true
					scene:action(am.play(chomp,false,1,0.2))
				end
			end
		end	

	end

end)

win.scene:action(am.play("img/song.ogg",true,1,0.2))
