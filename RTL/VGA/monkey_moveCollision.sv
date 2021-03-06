
// Monkey Moving and Collision


module	monkey_moveCollision	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					
					input logic jumpIsPressed,
					
					input logic digitIsPressed,
					input logic [3:0] digit,
					
					input logic collision,  //collision if monkey hits an object
					input	logic	[3:0] HitEdgeCode, //one bit per edge 

					output    logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[10:0]	topLeftY  // can be negative , if the object is partliy outside 
					
);


// a module used to generate the  ball trajectory.  

parameter int INITIAL_X = 0;
parameter int INITIAL_Y = 0;
parameter int INITIAL_X_SPEED = 40;
parameter int INITIAL_JUMP_SPEED = -200;
parameter int MAX_Y_SPEED = 230;
const int  Y_ACCEL = 5;

const int	FIXED_POINT_MULTIPLIER	=	64;
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we divide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions
const int	x_FRAME_SIZE	=	639 * FIXED_POINT_MULTIPLIER; // note it must be 2^n 
const int	y_FRAME_SIZE	=	479 * FIXED_POINT_MULTIPLIER;
const int	bracketOffset =	30;
const int   OBJECT_WIDTH_X = 64;

int Xspeed, topLeftX_FixedPoint; // local parameters 
int Yspeed, topLeftY_FixedPoint;

logic flag;
logic jumpFlag=1'b0;

// Moving left or right
always_ff@(posedge clk or negedge resetN)
begin
	if (!resetN) begin
	end
	else begin
		//collision executes once a frame
		//we have to counteract it in order to be able to change monkey's speed to stay off walls.
		if (startOfFrame) flag=1'b0;
	
		if (collision && (HitEdgeCode[3]||HitEdgeCode[1]) && !(HitEdgeCode[2]||HitEdgeCode[0])) begin
			flag=1'b1;
			if (HitEdgeCode[3]==1)//collision left wall
					Xspeed <= INITIAL_X_SPEED;
				else if (HitEdgeCode[1]==1) //collision right wall
					Xspeed <= INITIAL_X_SPEED*-1;
		end
	
		else if (flag==1'b0) begin
			if (digitIsPressed) begin
				if(digit==4) //pressing right
					Xspeed <= INITIAL_X_SPEED*-1;
				if (digit==6)//pressing left
					Xspeed <= INITIAL_X_SPEED;
			end
			else Xspeed<=0;
		end
	end
end


//Handles moving up/down and jumping
always_ff@(posedge clk or negedge resetN)
begin
	if (!resetN) begin
	end
	else begin
		if(collision && HitEdgeCode[2]==1 && (HitEdgeCode[3]==0 && HitEdgeCode[1]==0))
			Yspeed <= 10; //Hit top edge, -10 speed is just so the monkey can start falling
		
		else begin
			if(jumpIsPressed && jumpFlag!=1) begin
				jumpFlag=1'b1;
				Yspeed <= INITIAL_JUMP_SPEED; //Pressed the jump key
			end
			
			else if (collision && HitEdgeCode[0]==1 && !(HitEdgeCode[3]||HitEdgeCode[1])) begin
				Yspeed <= -30; //Hit bottom edge and didn't press jump, stay at same place.
				jumpFlag=1'b0;
			end
		end
		
		if (startOfFrame == 1'b1) begin
			if (Yspeed < MAX_Y_SPEED ) //  limit the spped while going down 
				Yspeed <= Yspeed + Y_ACCEL ; // deAccelerate : slow the speed down every clock tic
		end
	end
end


//////////--------------------------------------------------------------------------------------------------------------=
//  calculation of X Axis speed using and position calculate regarding X_direction key or colision

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
		//Xspeed	<= INITIAL_X_SPEED;
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
		topLeftY_FixedPoint <= INITIAL_Y *FIXED_POINT_MULTIPLIER;
	end
	else begin
				
	// collisions with the sides 			
				//if (collision && HitEdgeCode [3] == 1) begin  
					//if (Xspeed < 0 ); // while moving left
							//Xspeed <= -Xspeed ; // positive move right 
				//end
			
				//if (collision && HitEdgeCode [1] == 1 ) begin  // hit right border of brick  
					//if (Xspeed > 0 ); //  while moving right
							//Xspeed <= -Xspeed  ;  // negative move left    
				//end	
		   
			
		if (startOfFrame == 1'b1 )//&& Yspeed != 0) 
		begin
			topLeftX_FixedPoint <= topLeftX_FixedPoint + Xspeed;
			topLeftY_FixedPoint <= topLeftY_FixedPoint + Yspeed;
		end
					
	end
end

//get a better (64 times) resolution using integer   
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;    


endmodule
