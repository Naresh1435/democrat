import { Card, CardFooter, Image, Button } from "@nextui-org/react";

const Dashboard = () => {
	return (
		<>
			<Card isFooterBlurred radius='lg' className='border-none'>
				<Image
					alt='Woman listing to music'
					className='object-cover'
					height={200}
					src='https://avatars.githubusercontent.com/u/74228037?v=4'
					width={200}
				/>
				<CardFooter className='justify-between before:bg-white/10 border-white/20 border-1 overflow-hidden py-1 absolute before:rounded-xl rounded-large bottom-1 w-[calc(100%_-_8px)] shadow-small ml-1 z-10'>
					<p className='text-tiny text-white/80'>Available soon.</p>
					<Button
						className='text-black text-tiny bg-black/20'
						variant='flat'
						color='default'
						radius='lg'
						size='sm'
					>
						Notify me
					</Button>
				</CardFooter>
			</Card>
		</>
	);
};

export default Dashboard;