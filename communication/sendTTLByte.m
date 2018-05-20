function value = sendTTLByte( byte , usingDataPixx )
%SENDTTL Summary of this function goes here
%   Detailed explanation goes here


    
    if usingDataPixx
        if byte > 255
					fprintf('1-8 lines (pins 17-24) are available on dataPixx only!\n')
					return
        end
        
        val = bitshift(byte,16);
        mask = bitshift(byte,16);
        Datapixx('SetDoutValues', 0, mask);
        Datapixx('RegWr');
        Datapixx('SetDoutValues', val, mask);
        Datapixx('RegWr');
        WaitSecs(0.001);
        Datapixx('SetDoutValues', 0, mask);
        Datapixx('RegWr');
        
    end
    value = -1;
    switch line
        case 1
            value = 'Start';
        case 2 
            value = 'Broke Fix';
        case 3
            value = 'Fixation Achieved';
        case 4
            value = 'No Fix';
        case 5
            value = 'Not choose';
        case 6 
            value = 'Eyes on distractor';
        case 7 
            value = 'Mark';
    end
    disp(value);
    
        

end

