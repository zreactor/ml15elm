function SoundManager(msg) {
    warn_sound = new Audio('./pingping.m4a');
    end_sound = new Audio('./gong.m4a');

    if (msg == "WARNING_TIME") {
        warn_sound.play();
        console.log("Warning time", msg);

    } else if (msg == "END_TIME") {
        end_sound.play();
        console.log("End time *****", msg);

    } else { 
        console.log("SoundManager got a message:", msg);
    }  
  };