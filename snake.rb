require 'curses'
include Curses
require 'time'
require 'colored'


def change_of_dir
	case getch
	when ?Q, ?q
		exit
	when ?W, ?w
		@dir = 1 if @dir != 2
	when ?S, ?s
		@dir = 2 if @dir != 1
	when ?D, ?d
		@dir = 4 if @dir != 3
	when ?A, ?a
		@dir = 3 if @dir != 4
	when ?P, ?p
		#pause goes here...
	else 
		@dir
	end
end

def end_game
	exit
	puts "You LOST".red
end

def make_food(max_h, max_w)
	@food_y = rand(2..max_w-2)
	@food_x = rand(1..max_h-2)
end

init_screen
cbreak
noecho						#does not show input of getch
stdscr.nodelay = 1 			#the getch doesnt system_pause while waiting for instructions
curs_set(0)					#the cursor is invisible.


#starting position
title = "Kirka's Snake"
pos_y = [5,4,3,2,1]
pos_x = [1,1,1,1,1]
@dir = 4 #1 = up, 2 = down, 3 = left, 4 = right
snake_len = 3
width = cols
height = lines
game_speed = 0.2
make_food(height, width)
start_time = Time.now.to_i
speed_incremented = false
display_speed = 0
game_score = 0


begin
	loop do

		current_time = Time.now.to_i

		win = Window.new(height, width, (lines - height)/2, (cols - width)/2) #set the playfield the size of current terminal window
		win.box("|", "-")
		win.refresh

		win.setpos(@food_x, @food_y)
		win.addstr("#")

		win.setpos(0,3)
		win.addstr("Snake Length: " + snake_len.to_s)

		win.setpos(0,width/2-title.length/2)
		win.addstr(title)

		win.setpos(0,width-12)
		win.addstr("Time: " + (current_time - start_time).to_s)

		win.setpos(height-1,3)
		win.addstr("Speed: " + display_speed.to_s)

		win.setpos(height-1,width-12)
		win.addstr("Score: " + (game_score-(current_time - start_time)/10.round(0)).to_s)

		#change direction of movement
		case @dir
		when 1
			pos_x[0] -= 1
		when 2
			pos_x[0] += 1
		when 3
			pos_y[0] -= 1
		when 4
			pos_y[0] += 1
		end

		#remember the tail position during movement
		t = snake_len+1
		while t > 0 do
			pos_x[t] = pos_x[t-1]
			pos_y[t] = pos_y[t-1]
			t -= 1
		end 

		#draw the snake and its tail
		for t in 0..snake_len+1
			setpos(pos_x[t],pos_y[t])
			if t == 1
				addstr("*")
			else
				addstr("+")
			end
			win.refresh
		end

		change_of_dir

		#set speed of play, increment it automatically
		if ((snake_len % 10 == 0) or ((current_time-start_time)%60 == 0))
			if speed_incremented == false
				game_speed -= (game_speed*0.10) unless game_speed < 0.05
				speed_incremented = true
				display_speed += 1
			end
		else
			speed_incremented = false
		end

		if @dir == 2 or @dir == 1
			sleep(game_speed)
		elsif @dir == 3 or @dir == 4
			sleep(game_speed/2)
		end

		#check collision with border
		if pos_y[0] == cols-1 or pos_y[0] == 0 or pos_x[0] == lines-1 or pos_x[0] == 0
			end_game
		end

		#check collision with self
		for i in 2..snake_len
			if pos_y[0] == pos_y[i] and pos_x[0] == pos_x[i]
				end_game
			end
		end

		#check if ate food
		if pos_y[0] == @food_y and pos_x[0] == @food_x
			make_food(height,width)
			snake_len += 1
			game_score += 1*display_speed
		end
		win.close
	end
ensure
	close_screen
end