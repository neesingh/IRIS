function removeBorder( h )

    jh = findjobj(h);
    newBorder = javax.swing.border.LineBorder(java.awt.Color(0,0,0),0,0);
    jh.Border = newBorder;
    jh.setBorderPainted(false);    
    jh.setContentAreaFilled(false);
    jh.repaint;

end