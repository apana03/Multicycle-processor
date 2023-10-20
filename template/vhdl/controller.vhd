library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic;
        -- immediate value sign extention
        imm_signed : out std_logic;
        -- instruction register enable
        ir_en      : out std_logic;
        -- PC control signals
        pc_add_imm : out std_logic;
        pc_en      : out std_logic;
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
        -- register file enable
        rf_wren    : out std_logic;
        -- multiplexers selections
        sel_addr   : out std_logic;
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
        -- write memory output
        read       : out std_logic;
        write      : out std_logic;
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0)
    );
end controller;

architecture synth of controller is
    type state_type is (fetch1, fetch2, decode, r_op, store, break, load1, load2, i_op);
    signal state, next_state : state_type;
begin

    process(clk , reset_n)
    begin
        if reset_n = '0' then
            state <= fetch1;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;
    
    process(state, op, opx)
    begin
        next_state <= state;
        case state is
            when fetch1 =>
                next_state <= fetch2;
            when fetch2 =>
                next_state <= decode;
            when decode =>
                --  check if op = 0x3A
                if op = "111010" then
                    -- check if opx = 0x34
                    if opx = "110100" then
                        next_state <= break;
                    else
                        next_state <= r_op;
                    end if;
                -- check if op = 0x04
                elsif op = "000100" then
                    next_state <= i_op;
                -- check if op = 0x17
                elsif op = "010111" then
                    next_state <= load1;
                -- check if op = 0x15
                elsif op = "010101" then
                    next_state <= load1;
                else
                    next_state <= fetch1;
                end if;
            when r_op =>
                next_state <= fetch1;
            when store =>
                next_state <= fetch1;
            when break =>
                next_state <= break;
            when load1 =>
                next_state <= load2;
            when load2 =>
                next_state <= fetch1;
            when i_op =>
                next_state <= fetch1;
        end case;
    end process;




    read <= '1' when (state = fetch1) or (state = load1) else '0';
    pc_en <= '1' when state = fetch2 else '0';
    ir_en <= '1' when state = fetch2 else'0' ;
    rf_wren <= '1' when (state = i_op) or (state = r_op) or (state = load2) else '0';
    imm_signed <= '1' when (state = i_op) or (state = load1) else '0';
    sel_rC <= '1' when state = r_op else '0';
    sel_b <= '1' when (state = r_op) or (state = store) else '0';
    sel_addr <= '1' when (state = load1) or (state = store) else '0';
    sel_mem <= '1' when state = load2 else '0';
    write <= '1' when state = store else '0';

    --set unused to 0 for now
    branch_op <= '0';
    pc_add_imm <= '0';
    pc_sel_a <= '0';
    pc_sel_imm <= '0';
    sel_pc <= '0';
    sel_ra <= '0';
    
    process(op, opx)
    begin
        -- check if R-Type  
        if op = "111010" then
            -- check for "and" instruction
            if opx = "001110" then
                op_alu <= "100001";
            -- check for "shift right logical" instruction
            elsif opx = "011011" then
                op_alu <= "110011";
            end if;
        -- check if I-Type
        elsif op = "000100" then
            -- for now just do addition for I-Type
            op_alu <= "000000";
        end if;
    end process;

end synth;
