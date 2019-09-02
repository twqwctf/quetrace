{$X+}
program quetrace(input,output,outfile);

(********************************************************************************
 *										*
 * Program: quetrace								*
 * Programmer: Greg Fudala							*
 * Soc. sec #: xx-xx-xxxx							*
 * Due Date: January 31, 1989							*
 * System: Apple Mac II								*
 * Compiler: VP									*
 *  				   Purpose               			*
 *										*
 * This program illustrates the structure of a Queue Data Structure. The        *
 * modules that manipulate the queue structure are done in accordance to the    *
 * definition of a queue; that is, encapsulation is not being violated. The     *
 * program consists of a queue package- the modules that manipulate a queue,    *
 * and other modules that do not actually manipulate a queue. The queue package *
 * consists of the modules enq,deq,printque,quetraceenq,quetracedeq. The rest   *
 * of the program consists of modules that do not manipulate the queue, but     *
 * do other tasks like print a startup screen or determine whether a queue is   *
 * empty or not. Each module's description will specify whether it is part of   *
 * the queue package or not.          						*
 * The program also includes a trace facility which allows the user to 'see'    *
 * a queue even as it is being manipulated. A queue is actualy stored in an     *
 * array by which the program can manipulate(but not violate encapsulation) a   *
 * queue. The trace facility will be explained in detail below in the           *
 * appropriate module.								*
 * The program also outputs a queue to an output file when directed in the main *
 * driver of the program.                					*
 *										*
 * Input : None 								*
 * Output: Output of a queue is sent to the file 'output.que'			*
 *										*
 ********************************************************************************)
 

USES rawio;          (* allows the compiler to compile raw input/output *)

const
   maxqueue=100;      (* maximum number of elements allowed in a queue *)
   leastcol=31;       (* the leftmost column of the trace facility *)
   mostcol=51;        (* the rightmost column of the trace facility *)
   escape=27;         (* the ASCII representation for the escape <esc> char. *)
   firstrow=21;       (* the uppermost row of the trace facility *)
   secondrow=22;      (* the second row of the trace facility *)
   thirdrow=23;       (* the third row of the trace facility *)
   fourthrow=24;      (* the lowermost row of the trace facility *)
   leastelemcol=32;   (* the leftmost column of the element insertation of trace
                         facility *)
   mostelemcol=50;    (* the rightmost column of the element insertation of trace
                         facility *)
   numelemintrace=10; (* number of elements in trace *)
   toprowcol=1;       (* the lowest(value) low or column on the screen *)
   clearindex=0;      (* index which sets a queue to be clear *)
   wait=100000;       (* time delay *)
   blank=' ';         (* blank space *)
   bar='|';           (* bar for trace facility *)
   heading='front     QUEUE  rear';     (* trace heading *)
   horzbar='-';       (* horizontal bar for trace *)

type
   elementtype=char;        (* type for queue elements *)
   dummygetchar=char;       (* allows the user to hit a key of type char to 
                               continue *)
   indextype=0..maxqueue;   (* index type for the array which holds a queue *)

   (* a queue's type. Allows a queue to be expressed by its element/index,
      its front index, and its rear index *)
 
   queuetype=record
      elements:array[indextype] of elementtype;  
      front:indextype;
      rear:indextype;
   end;

var
   que1,                 (* a queue being declared *)
   tempqueue,           
   tempqueue2            (* tempqueue and tempqueue2 are two queues being declared
                            to allow the program to interchange elements of a
                            queue to avoid violating encapsulation *)

      :queuetype;

   ch,                   (* variable for the character being passed in to 
                            a queue module *)
   tmpch,                (* variable used in conjunction with the deq module
                            which allows the procedure to 'delete' an element *) 
   dequeuedelem          (* variable used in conjunction with the deq module
                            which allows the procedure to output by value
                            parameter the element which has been de-queued *)
      :elementtype;

   outfile      
      :text;              (* output file called 'output.que' *)
   time         
      :integer;           (* variable of time delay *)
   
procedure delay(var time:integer);

(********************************************************************************
 *										*
 * procedure :delay								*
 * purpose: This procedure simply delays a queue manipulation to allow the user *
 *          to see the changes (if any)                                         *
 *										*
 * parameters: recieves the variable parameter time.                            *
 * called by: the main driver							*
 * calls: none									*
 *										*
 ********************************************************************************)

   var y:integer;    (* counter *)

   begin
   for y:=1 to time do
      ;
   end;     (* delay *)

   
procedure quetraceoff(anyqueue:queuetype);

(********************************************************************************
 *										*
 * procedure: quetraceoff							*
 * Purpose: This procedure deletes the four lines where the trace facility      *
 *          appears.								*
 *										*
 * Parameters: recieves any queue.						*
 * Called by: possibly the main driver						*
 * Calls: none 									*
 *										*
 ********************************************************************************)

   var a:integer;    (* counter *)

   begin

   (* the following loop allows each line of the trace facility to be cleared
      by using the escape sequence <esc> [K which clears a line from left to
      right by first placing the cursor at the beginning of each line *)

   for a:=firstrow to fourthrow do
      begin
      write(chr(escape),'[');
      write(a div 10:1,a mod 10:1,';'); 
      write(toprowcol div 10:1,toprowcol mod 10:1,'H');
      write(chr(escape),'[K');
      end;
   end;      (* quetraceoff *) 


function emptyqueue(anyqueue:queuetype):boolean;  

(********************************************************************************
 *										*
 * Function: emptyqueue	        						*
 * Purpose: This function determines whether a queue is empty. If so, TRUE is   *
 *          returned, otherwise, FALSE						*
 *										*
 * Called by: the procedures deq, printque, and quetracedeq                     * 
 *										*
 ********************************************************************************) 

   begin
   emptyqueue:=anyqueue.rear=anyqueue.front;
   end;   (* emptyqueue *)

function fullqueue(anyqueue:queuetype):boolean;

(********************************************************************************
 *										*
 * Function: fullqueue    							*
 * Purpose: This function determines whether a queue is empty. If so, TRUE is   *
 *          returned, otherwise, FALSE						*
 *										*
 * Called by: the procedure enq							*
 *                                           					*
 ********************************************************************************)

   var nextrear:indextype;

   begin
   if (anyqueue.rear=maxqueue)
      then
         nextrear:=1
      else
         nextrear:=anyqueue.rear+1;

   fullqueue:=nextrear = anyqueue.front;

   end;     (* fullqueue *)


procedure enq(var anyqueue:queuetype;var ch:elementtype);

(********************************************************************************
 *										*
 * procedure: enq								*
 * Purpose: this procedure accepts a queue and a variable ch. It then tests     *
 *          for a fullqueue. If not, the rear increases by one(wraps around     *
 *          if necessary) and puts the ch parameter in the queues rear position *
 *										*
 * Called by: procedures printque, quetraceenq, quetracedeq, & possibly the     *
 *            main driver 							*
 * Calls: the function fullqueue						*
 *										*
 ********************************************************************************) 

   begin
   if (not (fullqueue(anyqueue)))
      then
      begin
      anyqueue.rear:=(anyqueue.rear mod maxqueue)+1;
      anyqueue.elements[anyqueue.rear]:=ch;
      end;
   end;   (* enq *)

procedure deq(var anyqueue:queuetype;tmpch:elementtype;var dequeuedelem
              :elementtype);

(********************************************************************************
 *										*
 * Procedure: deq								*
 * Purpose: this procedure recieves a queue, and the tmpch character. Then,     *
 *          the procedure tests for an empty queue. If not, the queue's front   *
 *          index is incremented. Then the element in this registar is          *
 *	    assigned to dequeuedelem which denotes the char being de-queued.    *
 *          Finally, the character's index is replaced by the null character    *
 *          tmpch. 								*
 * 										*
 * Called by: the procedures printque, quetracedeq, & possibly the main driver  *
 * Calls: the function emptyqueue						*
 *										*
 ********************************************************************************)

   begin
   if (not (emptyqueue(anyqueue)))
      then
      begin
      anyqueue.front:=(anyqueue.front mod maxqueue)+1;
      dequeuedelem:=anyqueue.elements[anyqueue.front];
      anyqueue.elements[anyqueue.front]:=tmpch;
      end;
   end;    (* deq *)

function sizequeue(anyqueue:queuetype):integer;

(********************************************************************************
 *										*
 * Function sizequeue								*
 * Purpose: This function determines the size of a queue. By comparing the      *
 *          front and rear indexes, the size of a queue can be obtained.        *
 *										*
 * Called by: procedures quetraceenq and quetracedeq				*
 *										*
 ********************************************************************************)

   begin
   if (anyqueue.front<=anyqueue.rear)
      then
         sizequeue:=anyqueue.rear-anyqueue.front
      else
         sizequeue:=(maxqueue)-(anyqueue.front-anyqueue.rear);

   end;   (* sizequeue *)

procedure printque(var anyqueue,tempqueue2:queuetype);

(********************************************************************************
 *										*
 * Procedure printque								*
 * Purpose: This procedure outputs a queue to the output file 'output.que'      *
 *          It outputs the queue's elements one by one by transferring them     *
 *          to a temporary queue called tempqueue2. Then the procedure          *
 *	    transfers them all back to the parameter queue.                     *
 *										* 
 * Called by: possibly the main driver                                          *
 * Calls: This procedure calls deq and enq in order to transfer elements. It    *
 *        also calls emptyqueue to determine when to stop de-queueing.          *
 *                                          					*
 ********************************************************************************)

   var dumchar,            (* null character to avoid using tmpch as this would
                              be a global variable *)
       transferelem        (* the de-queued element also used to avoid a global
                              variable *)
          :elementtype;
       
   begin

   writeln(outfile);
   tempqueue2.front:=anyqueue.front;
   tempqueue2.rear:=tempqueue2.front;

   (* tranfers elements in parameter anyqueue to tempqueue2 *)

   while (not(emptyqueue(anyqueue))) do
      begin
      deq(anyqueue,dumchar,transferelem);
      enq(tempqueue2,transferelem);
      write(outfile,transferelem);
      end;
   anyqueue.front:=tempqueue2.front;
   anyqueue.rear:=anyqueue.front;

   (* transfers elements in tempqueue2 back in parameter emptyqueue *)

   while (not(emptyqueue(tempqueue2))) do
      begin
      deq(tempqueue2,dumchar,transferelem);
      enq(anyqueue,transferelem);
      end;
   end;    (* printque *)

      

procedure showsize(anyqueue:queuetype);

(********************************************************************************
 *										*
 * Procedure showsize								*
 * Purpose: this procedure determines whether a queue is less than or equal     *
 *          to 10 elements. If so, the rightmost bar of the trace facility      *
 *          is added. If not, it is removed. 					*
 * 										*
 * Called by: The procedures quetraceon, quetraceenq and quetracedeq.           *
 * Calls: the function sizequeue						*
 *										*
 ********************************************************************************)

   var det:char;    (* the appropriate rightmost character *)

   begin
   if ((sizequeue(anyqueue))<=numelemintrace)
      then
         det:=bar
      else
         det:=blank;
   write(chr(escape),'[');
   write(secondrow div 10:1,secondrow mod 10:1,';');
   write(mostcol div 10:1,mostcol mod 10:1,'H');
   write(det);
   end;     (* showsize *)

   
procedure clearqueue(var anyqueue:queuetype);

(********************************************************************************
 *										*
 * Procedure clearqueue								*
 * Purpose: This procedure simply clears a queue by setting the rear and front  *
 *          indexes to the same number (0)					*
 * 										*
 * Called by: possibly the main driver						*
 * Calls: none. 								*
 *										*
 ********************************************************************************)	

   begin
   anyqueue.rear:=clearindex;
   anyqueue.front:=clearindex;
   end;    (* clearqueue *)

procedure quetraceclearque(var anyqueue:queuetype);

(********************************************************************************
 *										*
 * Procedure quetraceclearque							*
 * Purpose: This procedure clears a queue by calling the procedure clearqueue   *
 *          and then fills in the spaces intended for elements in the trace     *
 *          facility with blanks.						*
 * 										* 
 * Called by: possibly the main driver						*
 * Calls: the function clearqueue						*
 *										*
 ********************************************************************************)

   var b   
      :integer;       (* counter *)

   begin
   clearqueue(anyqueue);
   for b:= leastcol to mostcol do
      begin
      if ((b mod 2)=0)    (* print to even columns only *)
         then
         begin
         write(chr(escape),'[');
         write(secondrow div 10:1,secondrow mod 10:1,';');
         write(b div 10:1,b mod 10:1,'H');
         write(blank);
         end;
      end;
   end;     (* quetraceclearque *)


procedure quetraceon(var anyqueue:queuetype);

(********************************************************************************
 *										*
 * Procedure quetraceon								*
 * Purpose: this procedure prints the trace facility (outline) to the screen.   *
 *          Also, the rightmost character is determined and printed by the      *
 *          showsize procedure.							*
 *										*
 * Called by: possibly the main driver     					*
 * Calls: the procedure showsize						*
 *										*
 ********************************************************************************)

var i:integer;     (* counter *)

   begin

   (* loop to print appropriate character in trace outline *)

   for i:=leastcol to mostcol do
      begin
      write(chr(escape),'[');
      write(firstrow div 10:1,firstrow mod 10:1,';');
      write(i div 10:1,i mod 10:1,'H');
      write(horzbar);
      if (i mod 2)<>0    (* prints to even columns only *)
         then
            begin
            write(chr(escape),'[');
            write(secondrow div 10:1,secondrow mod 10:1,';');
            write(i div 10:1,i mod 10:1,'H');
            write(bar);
            end;
      write(chr(escape),'[');
      write(thirdrow div 10:1,thirdrow mod 10:1,';');
      write(i div 10:1,i mod 10:1,'H');
      write(horzbar);
      end;            (* quetraceon *)

   write(chr(escape),'[24;31H');
   write(heading);
   showsize(anyqueue);
   end;      

procedure clearscreen;

(********************************************************************************
 *										*
 * Procedure clearscreen							*
 * Purpose: This procedure simply clears the screen using the escape function   *
 *          seen below.								*
 * 										*
 * Called by: possibly the main driver						*
 * Calls: none. 								*
 *										*
 ********************************************************************************)
	

   begin   
   write(chr(escape),'[1;1H');
   write(chr(escape),'[J');
   end;  (* clearscreen *)

function getchar:char;

(********************************************************************************
 *										* 
 * Function getchar								*
 * Purpose: This function is called by the procedure startup. The function      *
 *          waits for the user to hit a key to continue. This 'dummygetchar'    *
 *          calls the function which allows the function to procede with the    *
 *          program								*
 *										*
 * Called by: the procedure startup						*
 *										* 
 ********************************************************************************)

var getch:char;     (* assigned to the functon name for the program to continue *) 

   begin
   direct_io;
   read(getch);
   normal_io;
   getchar:=getch;
   end;   (* getchar *)

procedure startup;

(********************************************************************************
 *										*
 * Procedure startup								*
 * Purpose: This procedure is a startup ot title screen for the program.        *
 *          It contains information on the program and programmer.              *
 *          									*
 * Called by: possibly the main driver                                          *
 * Calls: the function getchar to allow user to proceed at will.                *
 *										* 
 ********************************************************************************)
 
   var dummygetchar:char;   (* used to call function getchar *)

   begin
   write(chr(escape),'[1;1H');
   writeln('program : quetrace');
   writeln;  
   writeln('This program demonstrates the structure of a Queue Data Structure');
   writeln('Also included is a dynamid trace facility which allows the user to');
   writeln('see the changes to the queue structure as they are being changed.');
   writeln;
   writeln('Programmer : Greg Fudala');
   writeln('729 O Shaughnessey Hall');
   writeln('232-2915');
   writeln;
   writeln('Hit a key to continue');
   dummygetchar:=getchar;   (* function call to getchar *)
   end;     (* startup *)


procedure gotoxy(var anyqueue:queuetype;var row,col:integer);

(********************************************************************************
 *										*
 * Procedure gotoxy								*
 * Purpose: This procedure, after taken in a queue, row, and column, goes to    *
 *          the appropriate space in the trace where the element is to be       *
 *          placed.  								*
 *									        *
 * Called by: the procedures quetraceenq and quetracedeq.			*
 * Calls: none.									*
 *										*
 ********************************************************************************)
	

   begin
   write(chr(escape),'[');
   write(row div 10:1,row mod 10:1,';');
   write(col div 10:1,col mod 10:1,'H');
   end;      (* gotoxy *)


procedure quetraceenq(var anyqueue:queuetype;ch:elementtype);

(********************************************************************************
 *										*
 * Procedure quetraceenq							*
 * Purpose: This procedure, having been called with a queue parameter and a     *
 *          character, enqueues this character, ch, into the queue passed       *
 *          in. It then outputs this character into the trace outline in the    *
 *          appropriate space. The procedure determines the correct space by    *
 *          determining the size of the queue by calling sizequeue. The column  *
 *          position can be easily derived from there. Then gotoxy is called    *
 *          for the program to move to the correct spot in the trace. Once the  *
 *          char. is printed to the screen(if necessary), the procedure calls   *
 *          showsize which allows the user to see if the queue has exceeded     *
 *          10 elements.             						*
 *										*
 * Called by: possibly the main driver						*
 * Calls: sizequeue and showsize.                                               *
 *										*
 ********************************************************************************)
 
   var enqrowpos,        (* row position *)
       enqcolpos         (* column position *)
          :integer;
   begin
      enq(anyqueue,ch); 
      enqrowpos:=secondrow;
      enqcolpos:=((2*sizequeue(anyqueue)))+30;
      if ((sizequeue(anyqueue))<=10)          (* only print in trace *)
         then
         begin
         gotoxy(anyqueue,enqrowpos,enqcolpos);
         write(ch);
         end;
      showsize(anyqueue);
   end;


procedure quetracedeq(var anyqueue,tempqueue:queuetype;ch:elementtype);

(********************************************************************************
 *										*
 * Procedure quetracedeq							*
 * Purpose: This procedure dequeues an element fron the queue passed in. Then,  *
 *          a loop is run which transfers the elements of the queue to a        *
 *          temporary queue called tempqueue. In the loop, once an element has  *
 *          been dequeued, if the size of the queue is less than ot equal to    *
 *          ten elements, gotoxy is called and that character is printed in the *
 *          appropriate space in the trace. In essence, the original queue is   *
 *          being shifted to the left and being put in the temporary queue      *
 *          while shifting. The temporary queue is needed to avoid violating    *
 *          encapsulation. One entire shift is only the result of one           *
 *          dequeued element. then, a loop is run to fill in blanks in the      *
 *          trace where the shift left an element space in the trace open (if   *
 *          necessary) Then, the temporary queue, now with one dequeued element *
 *          (if the original queue was not empty), is moved back into the queue *
 *          parameter passed in. The procedure is called each time one element  *
 *          is to be dequeued. Finally, showsize is called to print the         *
 *          appropriate character to the screen dependant on the size. This     *
 *          procedure is called until the loop in the main driver runs out.     *
 *										*
 * Called by: possibly the main driver						*
 * Calls: deq, enq, emptyqueue, sizequeue, gotoxy, and showsize                 *
 *										*
 ********************************************************************************)

  var deqrowpos,       (* row position *)
      deqcolpos,       (* column position *)
      size,            (* size of the temporary queue plus one to account for
                          the extra dequeued element *)
      diff,            (* number of most element positions minus blank space to
                          account for empty spaces in the trace *)
      blankspace,      (* derives how many spaces to print a blank ,only
                          the even spaces *)
      previous,        (* allows the procedure to know what index the passed
                          in queue had before manipulating the queue. It is 
                          needed later when the procedure is called again. The
                          index for the passed in queue must be incremented
                          relative to its position before entering the procedure
                          beforehand *)
      y                (* counter *)
         :integer;

      dumchar,         (* dummy null char. used instead of tmpch to avoid
                          using global variables *)
      transferelem     (* the de-queued element also used to avoid global
                          variables *)    
         :elementtype;   

   begin
   previous:=anyqueue.front;
   deq(anyqueue,dumchar,transferelem);
   while (not(emptyqueue(anyqueue))) do
      begin
      deq(anyqueue,dumchar,transferelem);
      enq(tempqueue,transferelem);
      deqrowpos:=secondrow;
      deqcolpos:=((2*sizequeue(tempqueue)))+30;

(* prints shifted elements while shifting *)

      if ((sizequeue(tempqueue))<=10)
         then
         begin
         gotoxy(tempqueue,deqrowpos,deqcolpos);
         write(transferelem);
         end;
      end;


(* prints blanks where necessary *)

      size:=sizequeue(tempqueue)+1;
      blankspace:=(numelemintrace-size)*2;
      diff:=mostelemcol-blankspace;
      for y:=mostelemcol downto diff do
         if (diff>=leastelemcol) and ((y mod 2)=0) 
            then
            begin
            write(chr(escape),'[');
            write(secondrow div 10:1,secondrow mod 10:1,';');
            write(y div 10:1,y mod 10:1,'H');
            write(blank);
            end;


      anyqueue.front:=(previous mod maxqueue)+1; 
      anyqueue.rear:=anyqueue.front; 

(* putting elements in tempqueue back in anyqueue parameter *)

   while(not(emptyqueue(tempqueue))) do
      begin
      deq(tempqueue,dumchar,transferelem);
      enq(anyqueue,transferelem);
      end;

tempqueue.front:=anyqueue.front;
tempqueue.rear:=anyqueue.front;

   showsize(anyqueue);
 
   end;    (* quetracedeq *)

begin  (* main *)

time:=wait;                    (* time gets value of constant wait *)

rewrite(outfile,'output.que');    (* opens text file for output data *)

clearscreen;
startup;
clearscreen;
clearqueue(que1);
clearqueue(tempqueue);
quetraceon(que1);
for ch:='A' to 'E' do
   quetraceenq(que1,ch);
printque(que1,tempqueue2);
for ch:='F' to 'J' do
   quetraceenq(que1,ch);
delay(time);
printque(que1,tempqueue2);
for ch:='a' to 'e' do
   quetracedeq(que1,tempqueue,tmpch);
printque(que1,tempqueue2);
delay(time);
for ch:='<' to '@' do
   quetraceenq(que1,ch);
printque(que1,tempqueue2);
delay(time);
for ch:='r' to 'z' do
   quetraceenq(que1,ch);
printque(que1,tempqueue2);
delay(time);
quetraceoff(que1);
for ch:='a' to 'f' do
   quetracedeq(que1,tempqueue,tmpch);
printque(que1,tempqueue2);
delay(time);
for ch:='4' to '9' do
   enq(que1,ch);
printque(que1,tempqueue2);
delay(time);
quetraceon(que1);
for ch:='1' to '4' do
   quetracedeq(que1,tempqueue,tmpch);
printque(que1,tempqueue2);
delay(time);
quetraceclearque(que1);
quetraceoff(que1);
end.   (* main *)

