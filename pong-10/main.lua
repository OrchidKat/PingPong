push = require 'push'


-- library for class
Class = require 'class'

require 'Paddle'


require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')

	--set title of window screen
	love.window.setTitle('Pong')

	-- seed to maximize the random
	-- use current time
	math.randomseed(os.time())

	--FOR RETRO FONT
	smallFont = love.graphics.newFont('font.ttf',8)
	--winning font
	largeFont = love.graphics.newFont('font.ttf' , 16)
	-- for score font 
	scoreFont = love.graphics.newFont('font.ttf',32)
    --ACTIVE FONT TO SMALLFONT OBJECT
	love.graphics.setFont(smallFont)
	 
   -- intialize setup screen 
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = false,
		vsync = true
	})
    

	--player score
	player1Score = 0
	player2Score = 0

	servingPlayer = 1
	-- player 
	player1 = Paddle(10,30,5,20)
	player2 = Paddle(VIRTUAL_WIDTH -10,VIRTUAL_HEIGHT -30 ,5,20)

	-- ball in middle
	ball = Ball(VIRTUAL_WIDTH/2-2 , VIRTUAL_HEIGHT / 2-2 ,4,4)
	--menu
	gameState = 'start'
end

-- runs per frame by dt

function love.update(dt)


	if gameState == 'serve' then 

		ball.dy = math.random(-50,50)

		if servingPlayer == 1 then
			ball.dx = math.random(140,200)
		else
			ball.dx = -math.random(140,200)
		end
	elseif gameState =='play' then
		--detect bal collision with paddles
		--slightly altering to change course
		if ball:collides(player1) then
			ball.dx = - ball.dx  * 1.03
			ball.x = player1.x + 5

			--velocity same direction
			if ball.dy < 0 then
				ball.dy = -math.random(10,150)
			else
				ball.dy = math.random(10,150)
			end
		end
		if ball:collides(player2) then
			ball.dx = - ball.dx * 1.03
			ball.x = player2.x -4

			--keey velocity same direction
			if ball.dy < 0 then
				ball.dy = -math.random(10,150)
			else
				ball.dy = math.random(10,150)
			end
		end


		-- detect collision on upper lower boundary
		if ball.y <= 0 then 
			ball.y = 0
			ball.dy = - ball.dy
		end

		-- account for ball size
		if ball.y >= VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = -ball.dy
		end

		if ball.x < 0 then
			servingPlayer = 1
			player2Score = player2Score + 1

			if player2Score == 10 then 
				winningPlayer = 2
				gameState ='done'
			else 
				gameState ='serve'

				ball:reset()
			end
		end

		if ball.x > VIRTUAL_WIDTH then 
			servingPlayer = 2
			player1Score = player1Score +1


			if player1Score == 10 then 
				winningPlayer = 1
				gameState ='done'
			else 
				gameState ='serve'

				ball:reset()
			end
		end
	end

			
		--player 1 movements
	if love.keyboard.isDown('w') then 
		-- add negative padlle speed to currnt y scaled by dt
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('s') then 
		-- add positive paddle speed same as above
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end

    
	--player 2 movements
	if love.keyboard.isDown('up') then
		-- add negative paddle 
		player2.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('down') then
		-- add positive paddle
		player2.dy = PADDLE_SPEED
	else
		player2.dy = 0
	end

	-- UPDATE BALL
	if gameState == 'play' then
		ball:update(dt)
	end

	player1:update(dt)
	player2:update(dt)
end

-- for exit
function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	--if we press enter 
	elseif key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'serve'
		elseif gameState == 'serve' then
			gameState = 'play'
        elseif gameState == 'done' then
			gameState = 'serve'
			ball:reset()

			player1Score = 0
			player2Score = 0
		
			if winningPlayer == 1 then 
				servingPlayer = 2
			else
				servingPlayer = 1
			end
		end
	end
end


function love.draw()
	push:apply('start')
    --clear a screen with specific color
	love.graphics.clear(40/255,45/255,52/255,255/255)
	-- welcome text
	love.graphics.setFont(smallFont)

	--love.graphics.printf("Hello Pong!",0,20,VIRTUAL_WIDTH,'center')
	--draw score on left and right
	--switch font 
	--love.graphics.setFont(scoreFont)

	displayScore()


	if gameState == 'start' then
		love.graphics.setFont(smallFont)
		love.graphics.printf('Welcome to Pong!' , 0 , 10 , VIRTUAL_WIDTH , 'center')
		love.graphics.printf('PLease enter to begin!' , 0 , 20 , VIRTUAL_WIDTH , 'center')
    elseif gameState == 'serve' then 
		love.graphics.setFont(smallFont)
		love.graphics.printf('player' .. tostring(servingPlayer) ..  "'s serve" , 0 , 10 ,VIRTUAL_WIDTH , 'center')
		love.graphics.printf('please Enter to Serve!', 0 ,20, VIRTUAL_WIDTH , 'center')
	elseif gameState == 'play' then
	
	elseif gameState == 'done' then
		love.graphics.setFont(largeFont)
		love.graphics.printf('player' .. tostring(winningPlayer) .. 'wins!' , 0 ,10 , VIRTUAL_WIDTH , 'center')
		love.graphics.setFont(smallFont)
		love.graphics.printf('Press Enter to Restart! ', 0 ,30 , VIRTUAL_WIDTH , 'center')
	end

	player1:render()
	player2:render()

	--ball render
	ball:render()
    -- new function just to show fps
	displayFPS()
	
	push:apply('end')
end 
--function to display fps
function displayFPS()
	-- simple display
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0,255/255 , 0 , 255/255)
	love.graphics.print('FPS:' ..tostring(love.timer.getFPS()),10,10)
end

function displayScore()
	love.graphics.setFont(scoreFont)
	love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 -50 , VIRTUAL_HEIGHT/3)
	love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30 , VIRTUAL_HEIGHT/3)
end