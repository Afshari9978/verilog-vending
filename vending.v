module product_store(product_id, price, id, cost);
    // price rom
// if not available, price returns with 0000
    input  [3:0] product_id;
    output [3:0] price;
    output [3:0] id;
    input        cost;

    reg [3:0]    product_price_rom [0:15];
    reg [3:0]    product_count_ram [0:15];
    reg [3:0]    price;
    reg [3:0]    id;
    integer      file, i;

    initial begin
        $readmemb("product_price.mem", product_price_rom);
        $readmemb("product_count.mem", product_count_ram);
    end

    always @(product_id or cost) begin
        if (cost == 1'b1) begin
            product_count_ram[product_id] = product_count_ram[product_id]-1'b1;
        end else begin
            if (product_count_ram[product_id] > 4'b0000) begin
                id = product_id;
                price = product_price_rom[product_id];
            end else begin
                id = 4'b0000;
                price = 4'b0000;
            end
        end
    end

endmodule


module student_store(rw, student_id, write_credit, read_credit);
    input  [0:0] rw;
    input  [3:0] student_id;
    input  [3:0] write_credit;
    output [3:0] read_credit;

    reg [3:0]    read_credit;
    reg [3:0]    student_credit_ram [0:15];

    initial begin
        $readmemb("student_credit.mem", student_credit_ram);
    end

    always @ (* ) begin
        if (rw) begin
            read_credit = student_credit_ram[student_id];
        end else begin
            student_credit_ram[student_id] = write_credit;
        end
    end
endmodule

module vending(clk, reset, data, submit, result);

    input  [0:0] clk, reset, submit;
    input  [3:0] data;
    output [0:0] result;

    localparam IDLE = 0, PRODUCT = 1, STUDENT = 2, DONE = 3;
    reg [0:0]    result;
    reg [1:0]    state, next_state;
    wire   [3:0] price;
    wire   [3:0] credit;
    reg [3:0]    new_credit;
    wire   [3:0] product_id;
    reg          do_cost;
    product_store ps1(data, price, product_id, 1'b0);
        product_store ps2(product_id, ,, do_cost);
        student_store ssr(1'b1, data, , credit);
    student_store ssw(1'b0, data, new_credit,);

        // next state finder
    always @(posedge submit) begin
        next_state = state;
        case (state)
            IDLE: begin
                result = 1'b0;
                do_cost = 1'b0;
                if (price != 4'b0000) begin
                    next_state = PRODUCT;
                end else if (price == 4'b0000) begin
                    next_state = DONE;
                    result = 1'b0;
                end
            end
            PRODUCT: begin
                if (credit >= price) begin
                    next_state = STUDENT;
                    new_credit = credit-price;
                    do_cost = 1;
                end else begin
                    // if sucsessfull purchase, cost countity
                    next_state = DONE;
                    do_cost = 0;
                    result = 1'b0;
                end
            end

            STUDENT: begin
                next_state = DONE;
                result = 1'b1;
            end
            DONE: begin
                result = 1'b0;
                next_state = IDLE;
            end
        endcase
    end


        // next state clock
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result = 1'b0;
            do_cost = 1'b0;
            state = IDLE;
            next_state = IDLE;
        end else begin
            state = next_state;
        end
    end

endmodule
