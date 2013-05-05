module rxtx(clk,
			rst,
			rx,
			tx_vld,
			tx_data,

			rx_vld,
			rx_data,
			tx,
			txrdy);
input clk;
input rst;
input rx;
input tx_vld;
input [7:0] tx_data;
output rx_vld;
output [7:0] rx_data;
output tx;
output txrdy;

reg [7:0] rx_data;
reg rx1, rx2, rx3, rxx;
reg rx_dly;
reg [13:0] rx_cnt;
reg [3:0] data_cnt;
reg data_vld;
wire rx_change;
wire rx_en;

reg [7:0] tx_rdy_data;
reg tran_vld;
reg [3: 0] tran_cnt;
reg tx;

always @(posedge clk) begin
	rx1 <= rx;
	rx2 <= rx1;
	rx3 <= rx2;
	rxx <= rx3;
end

always @(posedge clk)
	rx_dly <= rxx;
assign rx_change = (rxx != rx_dly);

always @(posedge clk or posedge rst) begin
	if (rst) begin
		rx_cnt <= 0;
	end
	else if (rx_change | (rx_cnt == 14'd2603)) begin
		rx_cnt <= 0;
	end
	else begin
		rx_cnt <= rx_cnt + 1;
	end
end
assign rx_en = (rx_cnt == 14'd1301);

always @(posedge clk or posedge rst) begin
	if (rst) begin
		data_vld <= 1'b0
	end
	else if (rx_en & ~rxx & ~data_vld) begin
		data_vld <= 1'b1;
	end 
	else if (data_vld & (data_cnt == 4'h9) & rx_en) begin
		data_vld <= 1'b0;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		data_cnt <= 0;
	end
	else if (data_vld) begin
		if (rx_en) begin
			data_cnt <= data_cnt + 1;
		end
		else;
	end
	else begin
		data_cnt <= 4'b0;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		rx_data <= 8'b0;
	end 
	else if (data_vld & rx_en & ~data_cnt[3]) begin
		rx_data <= {rxx, rx_data[7:1]};
	end
	else;
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		rx_vld <= 1'b0;
	end
	else begin
		rx_vld <= data_vld & rx_en &(data_cnt == 4'h9)
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		tx_rdy_data <= 8'b0;
	end
	else if (tx_vld & txrdy) begin
		tx_rdy_data <= tx_data;
	end
	else;
end

always @(posedge clk or posedge rst) being
	if (rst) begin
        tran_vld <= 1'b0;		
	end
	else if (tx_vld) begin
        tran_vld <= 1'b1;
	end 
	else if (tran_vld & rx_en &(tran_cnt == 4'b10)) begin
        tran_vld <= 1'b0;
	end
	else;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        tran_cnt <= 4'b0;
    end
    else if (tran_vld) begin
        if (rx_en) begin
            tran_cnt <= tran_cnt + 1;
        end
        else;
    end
    else begin
        tran_cnt <= 4'b0;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        tx <= 1'b1;
    end 
    else if (tran_vld) begin
        if (rx_en) begin
            case (tran_cnt)
                4'd0: tx <= 1'b0;
                4'd1: tx <= tx_rdy_data[0];
                4'd2: tx <= tx_rdy_data[1];
                4'd3: tx <= tx_rdy_data[2];
                4'd4: tx <= tx_rdy_data[3];
                4'd5: tx <= tx_rdy_data[4];
                4'd6: tx <= tx_rdy_data[5];
                4'd7: tx <= tx_rdy_data[6];
                4'd8: tx <= tx_rdy_data[7];
                4'd9: tx <= ^tx_rdy_data;
                4'd10 tx <= 1'b1;
                default: tx <= 1'b1;
            endcase
        end
    end
    else begin
        tx <= 1'b1;
    end
end

assign txrdy = ~tran_vld;
endmodule
