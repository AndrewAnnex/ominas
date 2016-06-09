;=============================================================================
; exd_create_header
;
;=============================================================================
function exd_create_header, tail

 ;--------------------------------------
 ; html header stuff
 ;--------------------------------------
 head = ['<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', $
            '<html>']


 head = [head, $
            '<head>', $
            '<title>OMINAS Reference Guide</title>', $
            '</head>']

 head = [head, $
            '<body style="color: rgb(0, 0, 0); background-color: rgb(255, 255, 255);">', $
            '<table style="text-align: left; margin-left: auto; margin-right: auto; width: 800px;"border="0" cellpadding="5" cellspacing="2">', $
             '<tbody>', $
             '<tr align="justify">', $
             '<td style="background-color: rgb(170, 170, 70); color: rgb(255, 255, 255); vertical-align: middle; text-align: left;">', $
             '<b>OMINAS Reference Guide</b> </td>', $
             '</tr>', $
             '<tr>', $
             '<td style="vertical-align: top;">', $
             '<br />']




 ;--------------------------------------
 ; html closing stuff
 ;--------------------------------------
 tail = ['</td>', '</tr>', '</tbody>', '</table>', '</body>', '</html>']


 return, head
end
;=============================================================================


