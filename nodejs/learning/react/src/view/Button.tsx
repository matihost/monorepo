import React from 'react'

interface ButtonProps {
  buttonName: string
}

interface MyButtonProps {
  button: ButtonProps
}

// function MyButton({button}: MyButtonProps) {
//   return (
//     <button>{button.buttonName}</button>
//   );
// }

// function MyButton(x: MyButtonProps) {
//   return (
//     <button>{x.button.buttonName}</button>
//   );
// }

// const MyButton: React.FC<MyButtonProps> = ({ button }) => {
//   return (
//     <button>{button.buttonName}</button>
//   );
// };

const MyButton: React.FC<MyButtonProps> = (x) => {
  return <button>{x.button.buttonName}</button>
}

export default MyButton
