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
    type state_type is (fetch1, fetch2, decode, r_op, store, break, load1, load2, i_op, branch, call, callr, jmp, jmpi, i_op_imm , r_op_small_imm);
    signal s_op, s_opx : std_logic_vector(7 downto 0);
    constant  r_type : std_logic_vector(7 downto 0) := X"3A";
    signal state, next_state : state_type;
begin
    -- concatenate op and opx for easier comparison with hex values
    s_op <= "00" & op;
    s_opx <= "00" & opx;

    process(clk , reset_n)
    begin
        if reset_n = '0' then
            state <= fetch1;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;
    
    process(state, s_opx, s_op)
    begin
        next_state <= state;
        case state is
            when fetch1 =>
                next_state <= fetch2;
            when fetch2 =>
                next_state <= decode;
            when decode =>
                --  check if op = 0x3A
                if s_op = r_type then
                    -- check if opx = 0x34
                    if s_opx = X"34" then
                        next_state <= break;
                    elsif s_opx = X"1D" then
                        next_state <= callr;
                    elsif (s_opx = X"0D") or (s_opx = X"05") then
                        next_state <= jmp;
                    -- check if opx detects an R-type instruction with small immediate
                    elsif (s_opx = X"12") or (s_opx = X"1A") or (s_opx = X"3A") or (s_opx = X"02") then
                        next_state <= r_op_small_imm; 
                    else
                        next_state <= r_op;
                    end if;
                -- check if op signal detects an I-type instruction
                elsif (s_op = X"04") or (s_op = X"08") or (s_op = X"10") or (s_op = X"18") or (s_op = X"20") then
                    next_state <= i_op;
                -- check if op signal detects an I-type instruction with unsigned immediate
                elsif (s_op = X"0C") or (s_op = X"14") or (s_op = X"1C") or (s_op = X"28") or (s_op = X"30") then
                    next_state <= i_op_imm;
                -- check if op = 0x17
                elsif op = X"17" then
                    next_state <= load1;
                -- check if op = 0x15
                elsif op = X"15" then
                    next_state <= load1;
                elsif (s_op = X"36") or (s_op = X"26") or (s_op = X"16") or (s_op = X"1E") or (s_op = X"0E") or (s_op = X"06") or (s_op = X"2E") then
                    next_state <= branch;
                elsif (s_op = X"00") then
                    next_state <= call;
                elsif (s_op = X"01") then
                    next_state <= jmpi;
                else
                    next_state <= fetch1;
                end if;
            when break =>
                next_state <= break;
            when load1 =>
                next_state <= load2;
            when others =>
                next_state <= fetch1;
        end case;
    end process;

    -- set outputs according to state
    read <= '1' when (state = fetch1) or (state = load1) else '0';
    pc_en <= '1' when (state = fetch2) or (state = call) or (state = callr) or (state = jmp) or (state = jmpi) else '0';
    ir_en <= '1' when state = fetch2 else'0' ;
    rf_wren <= '1' when (state = i_op) or (state = r_op) or (state = load2) or (state = call) or (state = callr) or (state = i_op_imm) or (state = r_op_small_imm) else '0';
    imm_signed <= '1' when (state = i_op) or (state = load1) else '0';
    sel_rC <= '1' when (state = r_op) or (state = r_op_small_imm) else '0';
    sel_b <= '1' when (state = r_op) or (state = store) or (state = branch) else '0';
    sel_addr <= '1' when (state = load1) or (state = store) else '0';
    sel_mem <= '1' when state = load2 else '0';
    write <= '1' when state = store else '0';
    branch_op <= '1' when state = branch else '0';
    pc_add_imm <= '1' when state = branch else '0';
    pc_sel_a <= '1' when (state = callr) or (state = jmp) else '0';
    pc_sel_imm <= '1' when (state = call) or (state = jmpi) else '0';
    sel_pc <= '1' when (state = call) or (state = callr) else '0';
    sel_ra <= '1' when (state = call) or (state = callr) else '0';
    

    -- asynch process to set alu op according to instruction
    process(s_op, s_opx )
    begin
        -- check if R-Type then map 3 MSB from opx to 3 LSB of op_alu
        if s_op = r_type then
            op_alu(2 downto 0) <= s_opx(5 downto 3);
        -- check this later
        elsif s_op = X"06" then 
            op_alu(2 downto 0) <= "100";
        -- if I-Type then map 3 MSB from op to 3 LSB of op_alu
        else 
            op_alu(2 downto 0) <= s_op(5 downto 3);
        end if;
        
        -- check if logical operation is needed
        if (s_opx = X"1E") or (s_opx = X"16") or (s_opx = X"16") or (s_opx = X"06") or (s_opx = X"0E") or (s_op = X"0C") or (s_op = X"14") or (s_op = X"1C") then
            op_alu(5 downto 3) <= "100";
        elsif   (s_opx = X"02") or (s_opx = X"3A") or (s_opx = X"1A") or (s_opx = X"12") or (s_opx = X"0B") or (s_opx = X"03") or (s_opx = X"3B") or (s_opx = X"1B") or (s_opx = X"13") or (s_opx = X"1B") then
            op_alu(5 downto 3) <= "110";
        elsif  (s_opx = X"31") or (s_op = X"04") or (s_op = X"17") or (s_op = X"15") or (s_op = X"04") then
            op_alu(5 downto 3) <= "000";
        elsif (s_opx = X"39") then
            op_alu(5 downto 3) <= "001";
        elsif (s_opx = X"30") or (s_opx = X"28") or (s_opx = X"20") or (s_opx = X"18") or (s_opx = X"10") or (s_opx = X"08") or (s_op = X"0E") or (s_op = X"16") or (s_op = X"1E") or (s_op = X"26") or (s_op = X"2E") or (s_op = X"36") or (s_op = X"08") or (s_op = X"10") or (s_op = X"18") or (s_op = X"20") or (s_op = X"28") or (s_op = X"30") then
            op_alu(5 downto 3) <= "011";
        end if;
    end process;

end synth;
