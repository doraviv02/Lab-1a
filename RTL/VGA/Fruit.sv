module	Fruit	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					input   logic   collision,  //collision if smiley hits an object
					input	logic	[3:0] HitEdgeCode, //one bit per edge 

					output	 logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[10:0]	topLeftY,  // can be negative , if the object is partliy outside 
					output   logic Nexist
					
);


// a module used to generate the  ball trajectory.
  

parameter int INITIAL_X = 280;
parameter int INITIAL_Y = 185;

const int	FIXED_POINT_MULTIPLIER	=	64;
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions
const int	x_FRAME_SIZE	=	639 * FIXED_POINT_MULTIPLIER; // note it must be 2^n 
const int	y_FRAME_SIZE	=	479 * FIXED_POINT_MULTIPLIER;
const int	bracketOffset =	30;
const int   OBJECT_WIDTH_X = 64;
const int   OBJECT_WIDTH_Y = 64;


int topLeftX_FixedPoint; // local parameters 
int topLeftY_FixedPoint; 
int eaten = 0;

//////////--------------------------------------------------------------------------------------------------------------=
//  checks collision

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
		topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
	end
	else begin
	
		if(collision) begin
			eaten <= 1;
		end
	
	end
end

//get a better (64 times) resolution using integer   
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ; 
assign  Nexist = eaten;   


endmodule