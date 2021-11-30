
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_Ball,
			input	logic	drawing_request_1,
			input logic drawing_request_2,
			
			output logic collision, // active in case of collision between two objects
			output logic SingleHitPulse // critical code, generating A single pulse in a frame 
);

// drawing_request_Ball   -->  smiley
// drawing_request_1      -->  brackets
// drawing_request_2      -->  number/box 

assign colision_smiley_number = (drawing_request_Ball &&  drawing_request_2);

assign collision = ( (drawing_request_Ball &&  drawing_request_1)|| colision_smiley_number);// any collision 


logic flag ; // a semaphore to set the output only once per frame / regardless of the number of collisions 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
		SingleHitPulse <= 1'b0 ; 
	end 
	else begin 

			SingleHitPulse <= 1'b0 ; // default 
			if(startOfFrame) 
				flag = 1'b0 ; // reset for next time 
				
//		change the section below  to collision between number and smiley


if ( collision  && (flag == 1'b0)) begin 
			flag	<= 1'b1; // to enter only once 
			if (colision_smiley_number) SingleHitPulse <= 1'b1 ; 
		end
	end 
end

endmodule
