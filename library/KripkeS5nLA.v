(*
Inductive agent: Set :=
 one: agent
|two: agent
|three: agent.
*)

Definition agent := nat.

Inductive var: Set := p: agent->var.

Inductive formula:Set:=
 Top : formula
|Bottom : formula
|Atom : var -> formula
|Not : formula -> formula
|And : formula -> formula -> formula
|Or : formula -> formula -> formula
|Imp : formula -> formula -> formula
|K : agent -> formula -> formula
(* |E : formula -> formula *)
|C : formula -> formula.

Infix "/\_" := And (at level 52).
Infix "\/_" := Or (at level 52).
Infix "->_" :=  Imp (at level 51, right associativity).

Notation "~_" := Not.


Definition BiImp (phi psi: formula) :=
  (phi ->_ psi) /\_ (psi ->_ phi).
Infix "<->_" :=  BiImp (at level 51, right associativity).

Inductive label: Set :=
o: label | k: agent -> label | c: label.
(* k and c are labels for the modal connectives K and C *)

Inductive level: Set :=
 nil: level 
|cons: label -> level -> level.

Infix " :: " := cons ( at level 60 , right associativity ).

Definition Increase (l: level) (lab: label): level :=
  (cons lab l).
(* add a label in front of the list *)

Fixpoint Decrease (l: level): level :=
match l with 
  nil => nil 
 |(cons o l') => (cons o (Decrease l')) 
 |(cons (k i) l') => (cons o l') 
 |(cons c l') => (cons o l') 
end.
(* replace the first modal connective label in the list with o *)

Fixpoint Remove_o (l: level): level :=
match l with 
  nil => nil 
 |(cons o l') => (Remove_o l') 
 |(cons e l') => (cons e l') 
end.
(* remove all o's at the front of the list *)

Fixpoint Check_c (l: level): Prop :=
match l with 
  nil => False 
 |(cons o l') => (Check_c l') 
 |(cons (k i) l') => False 
 |(cons c l') => True 
end.

Fixpoint Check_k (i: agent) (l: level): Prop :=
match l with 
  nil => False 
 |(cons o l') => (Check_k i l') 
 |(cons c l') => False 
 |(cons (k a) l') => i=a 
end.

Definition EqLevel (l l': level) := (Remove_o l) = (Remove_o l').
(* two lists are equivalent if they are the same after
   removing all o's at the front of the lists *)

Inductive K_formula: formula -> formula -> Prop :=
 K1: forall (phi: formula) (i: agent), (K_formula (K i phi) phi)
|Kn: forall (phi psi: formula),
  (K_formula phi psi)->forall (i: agent),(K_formula (K i phi) psi).



Parameter Ass: level -> formula -> Prop.

Inductive Provable: level -> formula -> Prop :=
 truth: forall (n: level), (Provable n Top)
|ass: forall (phi: formula) (n: level),
  (Ass n phi) -> (Provable n phi)
|ass_at: forall (phi: formula) (l m: level),
  (EqLevel l m) -> (Ass l phi) -> (Provable m phi)
|andI: forall (phi1 psi2: formula) (n: level),
  (Provable n phi1) -> (Provable n psi2) ->
  (Provable n (And phi1 psi2))
|andE1: forall (phi1 phi2: formula) (n: level),
  (Provable n (And phi1 phi2)) -> (Provable n phi1)
|andE2: forall (phi1 phi2: formula) (n: level),
  (Provable n (And phi1 phi2)) -> (Provable n phi2)
|orI1: forall (phi1 phi2: formula) (n: level),
  (Provable n phi1) -> (Provable n (Or phi1 phi2))
|orI2: forall (phi1 phi2: formula) (n: level),
  (Provable n phi2) -> (Provable n (Or phi1 phi2))
|orE: forall (phi1 phi2 psi: formula) (n: level),
  (Provable n (Or phi1 phi2)) ->
  ((Ass n phi1) -> (Provable n psi)) ->
  ((Ass n phi2) -> (Provable n psi)) -> (Provable n psi)
|impI: forall (phi1 phi2: formula) (n: level),
  ((Ass n phi1) -> (Provable n phi2)) ->
  (Provable n (Imp phi1 phi2))
|biimpI: forall (phi1 phi2: formula) (n: level),
  ((Ass n phi1) -> (Provable n phi2)) ->
  ((Ass n phi2) -> (Provable n phi1)) ->
  (Provable n (BiImp phi1 phi2))
|impE: forall (phi1 phi2: formula) (n: level),
  (Provable n (Imp phi1 phi2)) ->
  (Provable n phi1) -> (Provable n phi2)
|biimpE1: forall (phi1 phi2: formula) (n: level),
  (Provable n (BiImp phi1 phi2)) ->
  (Provable n phi2) -> (Provable n phi1)
|biimpE2: forall (phi1 phi2: formula) (n: level),
  (Provable n (BiImp phi1 phi2)) ->
  (Provable n phi1) -> (Provable n phi2)
|negE: forall (phi psi: formula) (n: level),
  ((Provable n (Not psi))) ->
  ((Provable n (psi))) -> (Provable n phi)
|negI: forall (phi psi: formula) (n: level),
  ((Ass n phi) ->(Provable n (Not psi))) ->
  ((Ass n phi) -> (Provable n (psi))) -> (Provable n (Not phi))
|negEstar: forall (phi psi: formula) (n: level),
  ((Ass n (Not phi)) ->(Provable n (Not psi))) ->
  ((Ass n (Not phi)) -> (Provable n (psi))) -> (Provable n phi)
|notI: forall (phi: formula) (n: level),
  ((Ass n phi) -> (Provable n Bottom)) ->
  (Provable n (Not phi))
|notE: forall (phi: formula) (n: level),
  (Provable n phi) ->
  (Provable n (Not phi)) -> (Provable n Bottom)
|botE: forall (phi: formula) (n: level),
  (Provable n Bottom) -> (Provable n phi)
|notnotE: forall (phi: formula) (n: level),
  (Provable n (Not (Not phi))) -> (Provable n phi)
|KiE: forall (phi:formula) (l: level) (i: agent),
  (Check_k i l) -> (* there must be a (K i) *)
  (Provable (Decrease l) (K i phi)) -> (Provable l phi)
|KiI: forall (phi: formula) (l: level) (i: agent),
  (Provable (Increase l (k i)) phi) ->
  (Provable l (K i phi))
|CE: forall (phi: formula) (l: level),
  (Check_c l) = True -> (* there must be a C *)
  (Provable (Decrease l) (C phi)) -> (Provable l phi)
|CI: forall (phi: formula) (l: level),
  (Provable (Increase l c) phi) -> (Provable l (C phi))
|ck: forall (phi phi': formula) (n: level),
  (K_formula phi phi') ->
  (Provable n (C phi')) -> (Provable n phi)
|cfour: forall (phi: formula) (n: level),
  (Provable n (C phi)) -> (Provable n (C (C phi)))
|cfive: forall (phi: formula) (n: level),
  (Provable n (Not (C phi))) ->
  (Provable n (C (Not (C phi))))
|kt: forall (phi: formula) (n: level) (i: agent),
  (Provable n (K i phi)) -> (Provable n phi)
|kfour: forall (phi: formula) (n: level) (i: agent),
  (Provable n (K i phi)) -> (Provable n (K i (K i phi)))
|kfive: forall (phi: formula) (n: level) (i: agent),
  (Provable n (Not (K i phi))) ->
  (Provable n (K i (Not (K i phi)))).

Notation "'[' n ']'  '|-'  phi ":= (Provable n phi) (at level 60). 
Notation "'[' n ']'  ':'  phi ":= (Ass n phi) (at level 60). 

Ltac Truth := apply truth.
Ltac hyp n H :=
apply ass_at with n;
  (unfold EqLevel; unfold Remove_o; reflexivity) || (exact H)
.

Ltac hyp2 H :=
match goal with
| |- Provable ?n ?phi  => apply ass_at with n ;
  (unfold EqLevel; unfold Remove_o; reflexivity) || (exact H) 
end.
Ltac all_i X := intro X.
Ltac exi_i X := exists X.
Ltac con_i := apply andI.
Ltac con_e1 L := apply andE1 with (phi2 := L).
Ltac con_e2 R := apply andE2 with (phi1 := R).
Ltac dis_i1 := apply orI1.
Ltac dis_i2 := apply orI2.
Ltac dis_e L R H1 H2 := apply orE with (phi1 := L) (phi2 := R) ;
  [ |intro H1|intro H2].
(*
Ltac dis_e X H1 H2 :=
  match X with
  | ( L \/_ R) => apply orE with (phi1 := L) (phi2 := R) ;
    [ |intro H1|intro H2]
  end.
*)

Ltac imp_i H := apply impI; intro H.
Ltac imp_e P := apply (impE P).
Ltac iff_i H1 H2 := apply biimpI; [intro H1 | intro H2].
Ltac iff_e1 P := apply biimpE1 with (phi2 := P).
Ltac iff_e2 P := apply biimpE2 with (phi1 := P).
Ltac neg_e P := apply negE with (psi := P).
Ltac neg_i P H := apply negI with (psi := P); intro H.
Ltac neg_e' P H := apply negEstar with (psi := P); intro H.

(*
Ltac box_e := apply boxE;(unfold Remove_o; discriminate) || unfold Decrease.
Ltac box_i := apply boxI; unfold Increase.
*)

Ltac Ki_e P := apply KiE with P;
  (unfold Check_k; reflexivity) || unfold Decrease.
Ltac Ki_i := apply KiI; unfold Increase.
Ltac C_e := apply CE; (unfold Check_c; reflexivity) || unfold Decrease.
Ltac C_i := apply CI; unfold Increase.
Ltac KT P := apply kt with P.
Ltac K4 := apply kfour.
Ltac K5 := apply kfive.
Ltac CK P := apply ck with P; repeat first [apply K1|apply Kn].
Ltac C4 := apply cfour.
Ltac C5 := apply cfive.

Ltac Assumed := (apply ass; assumption) || assumption.
Ltac AssumedAt P := apply ass_at with P;
  (unfold EqLevel; unfold Remove_o; reflexivity) || assumption.

Ltac AndIntro := apply andI.
Ltac AndElim1 P :=apply andE1 with P.
Ltac AndElim2 P :=apply andE2 with P.
Ltac OrIntro1 := apply orI1.
Ltac OrIntro2 := apply orI2.
Ltac OrElim P1 P2 := apply (orE P1 P2).
Ltac ImpIntro := apply impI; intro.
Ltac ImpElim P := apply (impE P).
Ltac NotIntro := apply notI; intro.
Ltac NotElim P := apply (notE P).
Ltac BottomElim := apply botE.
Ltac NotNotElim := apply notnotE.
Ltac KiElim P := apply KiE with P;
  (unfold Check_k; reflexivity) || unfold Decrease.
Ltac KiIntro := apply KiI; unfold Increase.
Ltac CElim := apply CE; (unfold Check_c; reflexivity) || unfold Decrease.
Ltac CIntro := apply CI; unfold Increase.

Lemma LawOfExcludedMiddle:
forall (phi: formula) (n: level),
  (Provable n (Or phi (Not phi))).
Proof.
intros.
neg_e' ((~_ phi)) H.

neg_i (phi \/_ ~_ phi) H1.
hyp n H.
dis_i2.

hyp n H1.
neg_i (phi \/_ ~_ phi) H1.
hyp n H.
dis_i1.

hyp n H1.

Qed.

Ltac LEM := apply LawOfExcludedMiddle.
