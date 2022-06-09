pragma solidity ^0.4.0;
contract structExample
{
    struct Student
    {
        string name;
        uint rollNo;
        uint marks;
        string subject;

    }Student std1;

    function getResult()returns(string,uint,string,uint)
    {
        std1.name="JessiE";
        std1.rollNo=20;
        std1.subject="Solidity";
        std1.marks=89;

        return(std1.name,std1.rollNo,std1.subject,std1.marks);
    }
}