require 'curses'
include Curses
require 'time'
require 'colored'

class Snake
	def initialize
		@pos_y = [5,4,3,2,1]
		@pos_x = [1,1,1,1,1]
		@snake_len = 3
		@width = cols
		@height = lines
		@game_speed = 0.2
		@game_score = 0
		@display_speed = 0
		@game_score = 0
		make_food(@height,@width)
	end

	def check_wall_collision
		#check collision with border
		if @pos_y[0] == @width-1 or @pos_y[0] == 0 or @pos_x[0] == @height-1 or @pos_x[0] == 0
			GamePlay::end_of_game
		end
	end

	def check_self_collision
		#check collision with self
		for i in 2..snake_len
			if @pos_y[0] == @pos_y[i] and @pos_x[0] == @pos_x[i]
				GamePlay::end_of_game
			end
		end
	end

	def check_food_eaten(time_offset)
		#check if ate food
		if @pos_y[0] == @food_y and @pos_x[0] == @food_x
			make_food(@height,@width)
			@snake_len += 1
			@game_score += 1*@display_speed
		end
		setpos(height-1,width-12)
		addstr("Score: " + (@game_score-(time_offset)/10.round(0)).to_s)
	end

	def draw_snake
		#remember the tail position during movement
		t = @snake_len+1
		while t > 0 do
			@pos_x[t] = @pos_x[t-1]
			@pos_y[t] = @pos_y[t-1]
			t -= 1
		end 
		#draw the snake and its tail
		for t in 0..@snake_len+1
			setpos(@pos_x[t],@pos_y[t])
			addstr(t == 1 ? "*" : "+")
		end
		setpos(0,3)
		addstr("Snake Length: " + @snake_len.to_s)
	end

	def make_food(max_h, max_w)
		@food_y = rand(2..max_w-2)
		@food_x = rand(1..max_h-2)
	end
end

class GamePlay < Snake
	def initialize
		@dir = :right
		@pause = false
		@speed_incremented = false
	end

	def change_direction_detect
		case getch
		when ?Q, ?q
			exit
		when ?W, ?w
			@dir = :up if @dir != :down
		when ?S, ?s
			@dir = :down if @dir != :up
		when ?D, ?d
			@dir = :right if @dir != :left
		when ?A, ?a
			@dir = :left if @dir != :right
		when ?P, ?p
			@pause = @pause ? false : true
			if @pause
				sleep(0.5)
				next
			end
		end

	def change_direction_update
		case @dir
		when :up    then @pos_x[0] -= 1
		when :down  then @pos_x[0] += 1
		when :left  then @pos_y[0] -= 1
		when :right then @pos_y[0] += 1
		end
	end

	def end_of_game
		puts "You LOST".red
		exit
	end

	def proper_delay
		sleep( (@dir == :left or @dir == :right) ? @game_speed/2 : @game_speed)
	end

	def speed_of_game(time_offset)
		#set speed of play, increment it automatically
		if ((@snake_len % 10 == 0) or (time_offset%60 == 0))
			if @speed_incremented == false
				@game_speed -= (@game_speed*0.10) unless @game_speed < 0.05
				@speed_incremented = true
				@display_speed += 1
			end
		else
			@speed_incremented = false
		end
		setpos(height-1,3)
		addstr("Speed: " + @display_speed.to_s)
	end
end


init_screen
cbreak
noecho						#does not show input of getch
stdscr.nodelay = 1 			#the getch doesnt system_pause while waiting for instructions
curs_set(0)					#the cursor is invisible.


#starting position
title = "Kirka's Snake"
start_time = Time.now.to_i
speed_incremented = false
display_speed = 0
win = Window.new(lines, cols, 0, 0) #set the playfield the size of current terminal window

begin
	loop do
		Snake.new
		GamePay.new

		time_offset = Time.now.to_i - start_time

		win.box("|", "-")

		win.setpos(@food_x, @food_y)
		win.addstr("#")

		win.setpos(0,width/2-title.length/2)
		win.addstr(title)

		win.setpos(0,width-12)
		win.addstr("Time: " + time_offset.to_s)

		Snake::draw_snake
		GamePlay::change_direction_detect
		GamePlay::speed_of_game(time_offset)
		GamePlay::change_direction_update
		Snake::check_wall_collision
		Snake::check_self_collision
		Snake::check_food_eaten(time_offset)
		GamePlay::proper_delay

		win.refresh
		win.clear
	end
ensure
	close_screen
end