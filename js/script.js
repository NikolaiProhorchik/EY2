class ButtonController{

    static uploadController(){
        let handle = function (){
            document.getElementById('uploadAndShowButtons').style.display = 'none';
            document.getElementById('uploadFile').style.display = 'flex';
        };
        let upload = document.getElementById('buttonUpload');
        upload.addEventListener('click', handle);
    }

    static backController(){
        let handle = function (){
            document.getElementById('uploadAndShowButtons').style.display = 'block';
            document.getElementById('uploadFile').style.display = 'none';
        };
        let back = document.getElementById('buttonBack');
        back.addEventListener('click', handle);
    }

    static showController(){
        let handle = function (){
            location.href='/showFiles';
        };
        let show = document.getElementById('buttonShow');
        show.addEventListener('click', handle);
    }
}

ButtonController.uploadController();
ButtonController.backController();
ButtonController.showController();
