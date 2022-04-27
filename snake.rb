require 'gosu'

class Map
    attr_reader :width, :height
    def initialize(width, height)
        @width = width
        @height = height
    end
end

class SnakeGame < Gosu::Window
    module Z
        Text = 1
    end
    
    MAP_WIDTH = 64
    MAP_HEIGHT = 48
    SCREEN_WIDTH = MAP_WIDTH * 10
    SCREEN_HEIGHT = MAP_HEIGHT * 10

    TEXT_COLOR = Gosu::Color::WHITE

    def initialize
        super(SCREEN_WIDTH, SCREEN_HEIGHT, false, 60)
        
        @map = Map.new(MAP_WIDTH, MAP_HEIGHT)
        @font = Gosu::Font.new(self, Gosu.default_font_name, 50)
        @paused = false

        reset_game
    end

    def reset_game
        @apple_position = {:x => @map.width / 3, :y => @map.height / 3}

        @snake = []
        @direction = :right
        @position = {:x => @map.width/3, :y => @map.height/3}
        (1..6).each { |n| @snake << {:x => -n, :y => @map.height / 3} }
    end

    def update
        return if @paused

        @position[:x] += case @direction
        when :left then -1
        when :right then 1
        else 0
        end

        @position[:y] += case @direction
        when :up then -1
        when :down then 1
        else 0
        end

        @snake.each do |location|
            case
            when @snake.include?(@position) then you_died
            when location[:x] == 0 || location[:x] == @map.width - 1 then you_died
            when location[:y] == 0 || location[:y] == @map.height - 1 then you_died
            end
        end

        @snake << {:x => @position[:x], :y => @position[:y]}

        if @position == @apple_position then
            @snake.unshift({:x => @position[:x], :y => @position[:y]})
            while @snake.index(@apple_position)
                @apple_position = {:x => rand(@map.width + 1), :y => rand(@map.height + 1)}
            end
        end

        @snake.shift

    end

    def you_died
        @text = "You died!"
        @draw_text_now = true
        p @text
        @paused = true
        reset_game
    end

    def button_down(id)
        case id 
        when Gosu::KbSpace then @paused = !@paused
        when Gosu::KbEscape then close
        end

        @direction = case id
            when Gosu::KbRight then @direction == :left ? @direction : :right
            when Gosu::KbUp then @direction == :down ? @direction : :up
            when Gosu::KbLeft  then @direction == :right ? @direction : :left
            when Gosu::KbDown  then @direction == :up ? @direction : :down
            else @direction
          end
    end
    def draw 
        snake_color = Gosu::Color.new(0xff00ff00)
        apple_color = Gosu::Color.new(0xffff0000)
        @snake.each do |part|
            draw_quad(
                part[:x]*10, part[:y] *10, snake_color,
                part[:x]*10+10, part[:y]*10, snake_color,
                 part[:x]*10, part[:y]*10+10, snake_color,
                 part[:x]*10+10, part[:y]*10+10, snake_color
            )

        end
        draw_quad(
            @apple_position[:x]*10, @apple_position[:y]*10, apple_color,
               @apple_position[:x]*10+10, @apple_position[:y]*10, apple_color,
               @apple_position[:x]*10, @apple_position[:y]*10+10, apple_color,
               @apple_position[:x]*10+10, @apple_position[:y]*10+10, apple_color
        )

        if @draw_text_now
            draw_text(@text)
            @draw_text_now = false unless @paused
        end
    end

    def draw_text(text)
        text_width = @font.text_width(text)

        @font.draw(
            text,
            (SCREEN_WIDTH/2) - (text_width/2),
            (SCREEN_HEIGHT/2) - (10),
            Z::Text,
            1.0,1.0,
            TEXT_COLOR
        )
    end
end
SnakeGame.new.show