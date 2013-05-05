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
wire rx_change, rx_en;

reg [7:0] tx_rdy_data;

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

endmodule
