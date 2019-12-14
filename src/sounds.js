function SoundManager(msg) {
    warn_sound = new Audio('./catmeow.m4a');
    end_sound = new Audio('./pingping.m4a');
    audiofile = new Audio('./testmemo.m4a');
    

    if (msg == "WARNING_TIME") {
        warn_sound.play();
        console.log("Warning time", msg);

    } else if (msg == "END_TIME") {
        end_sound.play();
        console.log("End time *****", msg);

    } else {
        
        console.log("Start clock:", msg);
        // audiofile.play();
        // warn_sound.play();
        // end_sound.play();
    }
    
      
      
  };