%%%hello matt, how are you?
%I'm great Eric, thanks. This seems to be working.
for i = 1:5
    fprintf('yay');
end


far_out = 1;
this_is_neat = 0;

while far_out == 1
    this_is_neat = this_is_neat + 1;
    
    if mod(this_is_neat, 1000) == 0
        far_out = 0;
    end
    
end

disp(this_is_neat);