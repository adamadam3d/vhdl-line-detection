library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PrewittLineDetector is
    Generic (
        threshold : INTEGER := 125
    );
    Port (
        startx : out INTEGER;
        starty : out INTEGER;
        endx   : out INTEGER;
        endy   : out INTEGER;
		  cordx1,cordy1,cordx2,cordy2 : out STD_LOGIC_VECTOR(6 downto 0);
		  testout : out STD_LOGIC_VECTOR(19 downto 0) := "11111111111111111111" --force middle numbers and DPs to be off
    );
end PrewittLineDetector;

architecture Behavioral of PrewittLineDetector is

    type matrix3x3 is array (0 to 2, 0 to 2) of INTEGER;
    constant inpx : matrix3x3 := (
        ( -1, 0, 1 ),
        ( -1, 0, 1 ),
        ( -1, 0, 1 )
    );

    type matrix10x10 is array (0 to 9, 0 to 9) of INTEGER;
    constant img : matrix10x10 := (
        ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
    );

    -- variable ans : matrix10x10 := (
    --     ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ),
    --     ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
    --     ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
    --     ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
    --     ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
    --     ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
    --     ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
    --     ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ),
    --     ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ),
    --     ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
    -- );

    function matrix_multiplication(
        x : INTEGER; 
        y : INTEGER; 
        img : matrix10x10; 
        inp : matrix3x3
    ) return INTEGER is
        variable result : INTEGER := 0;
    begin
        for i in 0 to 2 loop
            for j in 0 to 2 loop
                result := result + inp(i, j) * img(x + i - 1, y + j - 1);
            end loop;
        end loop;
        return abs(result);
    end function;

begin
    process
    variable temp_startx, temp_starty, temp_endx, temp_endy : INTEGER := 0;
    variable ans : matrix10x10 := (
        ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 255, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ),
        ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
    );
    begin
        --report integer'image(temp_startx);
        -- Compute convolution and populate ans
        for x in 1 to 8 loop
            for y in 1 to 8 loop
                ans(x, y) := matrix_multiplication(x, y, img, inpx);
                report integer'image(ans(x, y));
            end loop;
        end loop;

        -- Apply threshold and determine bounding box
        for x in 1 to 8 loop
            for y in 1 to 8 loop
                if ans(x, y) > threshold then
                    ans(x, y) := 1;
                    if temp_startx = 0 and temp_starty = 0 then
                        temp_startx := y;
                        temp_starty := x;
                    else
                        temp_endx := y;
                        temp_endy := x;
                    end if;
                else
                    ans(x, y) := 0;
                end if;
            end loop;
        end loop;

        -- Assign final results
        startx <= temp_startx;
        starty <= temp_starty;
        endx <= temp_endx;
        endy <= temp_endy;
		  
         --report integer'image(temp_startx);
		  case temp_startx is
            when 0 => cordx1 <= "1000000"; -- Case for 0
            when 1 => cordx1 <= "1111001"; -- Case for 1
            when 2 => cordx1 <= "0100100"; -- Case for 2
            when 3 => cordx1 <= "0110000"; -- Case for 3
            when 4 => cordx1 <= "0011001"; -- Case for 4
            when 5 => cordx1 <= "0010010"; -- Case for 5
            when 6 => cordx1 <= "0000010"; -- Case for 6
            when 7 => cordx1 <= "1111000"; -- Case for 7
            when 8 => cordx1 <= "0000000"; -- Case for 8
            when 9 => cordx1 <= "0010000"; -- Case for 9
            when others => cordx1 <= "1111111"; -- Case for invalid inputs
        end case;
		  
		  case temp_starty is
            when 0 => cordy1 <= "1000000"; -- Case for 0
            when 1 => cordy1 <= "1111001"; -- Case for 1
            when 2 => cordy1 <= "0100100"; -- Case for 2
            when 3 => cordy1 <= "0110000"; -- Case for 3
            when 4 => cordy1 <= "0011001"; -- Case for 4
            when 5 => cordy1 <= "0010010"; -- Case for 5
            when 6 => cordy1 <= "0000010"; -- Case for 6
            when 7 => cordy1 <= "1111000"; -- Case for 7
            when 8 => cordy1 <= "0000000"; -- Case for 8
            when 9 => cordy1 <= "0010000"; -- Case for 9
            when others => cordy1 <= "1111111"; -- Case for invalid inputs
        end case;
		  
		  case temp_endx is
            when 0 => cordx2 <= "1000000"; -- Case for 0
            when 1 => cordx2 <= "1111001"; -- Case for 1
            when 2 => cordx2 <= "0100100"; -- Case for 2
            when 3 => cordx2 <= "0110000"; -- Case for 3
            when 4 => cordx2 <= "0011001"; -- Case for 4
            when 5 => cordx2 <= "0010010"; -- Case for 5
            when 6 => cordx2 <= "0000010"; -- Case for 6
            when 7 => cordx2 <= "1111000"; -- Case for 7
            when 8 => cordx2 <= "0000000"; -- Case for 8
            when 9 => cordx2 <= "0010000"; -- Case for 9
            when others => cordx2 <= "1111111"; -- Case for invalid inputs
        end case;
		  
		  case temp_endy is
            when 0 => cordy2 <= "1000000"; -- Case for 0
            when 1 => cordy2 <= "1111001"; -- Case for 1
            when 2 => cordy2 <= "0100100"; -- Case for 2
            when 3 => cordy2 <= "0110000"; -- Case for 3
            when 4 => cordy2 <= "0011001"; -- Case for 4
            when 5 => cordy2 <= "0010010"; -- Case for 5
            when 6 => cordy2 <= "0000010"; -- Case for 6
            when 7 => cordy2 <= "1111000"; -- Case for 7
            when 8 => cordy2 <= "0000000"; -- Case for 8
            when 9 => cordy2 <= "0010000"; -- Case for 9
            when others => cordy2 <= "1111111"; -- Case for invalid inputs
        end case;
        wait until temp_endx /= 0 for 100 ns; 
    end process;
end Behavioral;