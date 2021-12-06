with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;
with Aoc_Helper;           use Aoc_Helper;
with Ada.Containers.Vectors;

procedure Aoc_04a
is
   subtype Value_Range is Integer range 0 .. 99;
   subtype Row_Range is Integer range 1 .. 5;
   subtype Col_Range is Row_Range;

   type Board is array (Row_Range, Col_Range) of Value_Range;
   type Board_Checks is array (Row_Range, Col_Range) of Boolean;
   Unchecked : constant Board_Checks := (others => (others => False));

   function Bingo (B : Board_Checks) return Boolean
   is
      Set : Boolean := True;
   begin
      for C in Col_Range loop
         for R in Row_Range loop
            Set := Set and B (C, R);
         end loop;
         if Set then return True; end if;
         Set := True;
      end loop;
      for C in Col_Range loop
         for R in Row_Range loop
            Set := Set and B (R, C);
         end loop;
         if Set then return True; end if;
         Set := True;
      end loop;
      return False;
   end Bingo;

   procedure Print (B : Board_Checks)
   is
   begin
      for C in Col_Range loop
         for R in Row_Range loop
            Put ((if B(C, R) then "1 " else "0 "));
         end loop;
         New_Line;
      end loop;
      New_Line;
   end Print;


   use Int_Vec;
   Drawn_Numbers : Vector;

   package Board_Vecs is new Ada.Containers.Vectors (Element_Type => Board,
                                                     Index_Type => Positive);
   Boards : Board_Vecs.Vector;
   package Checks_Vecs is new Ada.Containers.Vectors (Element_Type => Board_Checks,
                                                      Index_Type => Positive);
   Checks : Checks_Vecs.Vector;

   -- Check (Boards(Ind), Checks(Ind), N);
   procedure Check (B : Board; Ck : in out Board_Checks; Val : Value_Range)
   is
   begin
      for C in Col_Range loop
         for R in Row_Range loop
            if B (C, R) = Val then
               Ck (C, R) := True;
            end if;
         end loop;
      end loop;
   end Check;


   function Sum_Of_Unmarked (Idx : Positive) return Natural
   is
      Sum : Natural := 0;
      Ck  : Board_Checks renames Checks(Idx);
      B   : Board renames Boards (Idx);
   begin
      for C in Col_Range loop
         for R in Row_Range loop
            if not Ck(C, R) then
               Sum := Sum + B(C, R);
            end if;
         end loop;
      end loop;
      return Sum;
   end Sum_Of_Unmarked;

   Found : Boolean;
   Sum : Natural;

begin
   Open_Input;

   Read_Random_Numbers:
   declare
      Number_Line : constant String := Get_Line(Input);
      Pos : Natural := Number_Line'First;
      Last : constant Positive := Number_Line'Last;
      Rnd : Value_Range;
   begin
      loop
         Get (Number_Line (Pos..Last), Rnd, Pos);
         Drawn_Numbers.Append (Rnd);
         -- skip comma
         Pos := @+2;
      end loop;
   exception
   when End_Error => null;
   end Read_Random_Numbers;

   Read_Boards:
   declare
      Nr : Value_Range;
      B : Board;
   begin
      while not End_Of_File(Input) loop
         for C in Col_Range loop
            for R in Row_Range loop
               Get (Input, Nr);
               B (C, R) := Nr;
            end loop;
         end loop;
         Boards.Append (B);
      end loop;
   end Read_Boards;

   Checks := Checks_Vecs.To_Vector (Unchecked, Boards.Length);

   Numbers:
   for N of Drawn_Numbers loop
      for Ind in 1 .. Natural(Boards.Length) loop
         Check (Boards(Ind), Checks(Ind), N);
         Found := Bingo (Checks(Ind));
         if Found then
            Put_Line ("BINGO!");
            Put_Line ("winning number:" & N'Image);
            Put_Line ("winning board:" & Ind'Image);
            for C in Col_Range loop
               for R in Row_Range loop
                  Put (Boards(Ind)(C, R)'Image);
               end loop;
               New_Line;
            end loop;
            New_Line;
            Print (Checks(Ind));
            Sum := Sum_Of_Unmarked (Ind);
            Put_Line ("sum of unmarked"& Sum'Image);
            Put_Line ("score" & Integer'(Sum * N)'Image);
            exit Numbers;
         end if;
      end loop;
   end loop Numbers;

end Aoc_04a;
