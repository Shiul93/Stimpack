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
    disp('Sending Byte')
    disp(byte);
    
        

end

