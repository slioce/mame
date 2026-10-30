// license:GPL-2.0+
// copyright-holders:Stuart Carnie, Alessandro Lioce
#import <Foundation/Foundation.h>
#import "oecommon.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(uint64_t, GameDriverOptions)
{
	// system flags (game_driver::flags / machine_flags)

	/*! screen flip support is missing */
	GameDriverMachineNoCocktail = 0x0000000000000040,

	/*! this driver entry is a BIOS root */
	GameDriverMachineIsBiosRoot = 0x0000000000000080,

	/*! requires external artwork for key game elements */
	GameDriverMachineRequiresArtwork = 0x0000000000000100,

	/*! unofficial hardware modification */
	GameDriverMachineUnofficial = 0x0000000000000200,

	/*! system has no sound output */
	GameDriverMachineNoSoundHw = 0x0000000000000400,

	/*! contains mechanical parts (pinball, redemption games, ...) */
	GameDriverMachineMechanical = 0x0000000000000800,

	/*! official system with blatantly incomplete hardware/software */
	GameDriverMachineIsIncomplete = 0x0000000000001000,

	// flags that map to device emulation flags and feature flags

	/*! driver is not in a working state */
	GameDriverMachineNotWorking               = 0x0000000100000000,

	/*! system supports save states */
	GameDriverMachineSupportsSave             = 0x0000000200000000,

	/*! game's protection not fully emulated */
	GameDriverMachineUnemulatedProtection     = 0x0000000400000000,

	/*! colors are totally wrong */
	GameDriverMachineWrongColors              = 0x0000000800000000,

	/*! colors are not 100% accurate, but close */
	GameDriverMachineImperfectColors          = 0x0000001000000000,

	/*! graphics are wrong/incomplete */
	GameDriverMachineImperfectGraphics        = 0x0000002000000000,

	/*! sound is missing */
	GameDriverMachineNoSound                  = 0x0000004000000000,

	/*! sound is known to be wrong */
	GameDriverMachineImperfectSound           = 0x0000008000000000,

	/*! controls are known to be imperfectly emulated */
	GameDriverMachineImperfectControls        = 0x0000010000000000,

	/*! any game/system that has unemulated audio capture device */
	GameDriverMachineNoDeviceMicrophone       = 0x0000020000000000,

	/*! any game/system that has unemulated hardcopy output device */
	GameDriverMachineNoDevicePrinter          = 0x0000040000000000,

	/*! any game/system that has unemulated local networking */
	GameDriverMachineNoDeviceLan              = 0x0000080000000000,

	/*! timing is known to be imperfectly emulated */
	GameDriverMachineImperfectTiming          = 0x0000100000000000,

	// useful combination flags

	/*! flag combination for skeleton drivers */
	GameDriverMachineIsSkeleton               = GameDriverMachineNoSound | GameDriverMachineNotWorking,

	/*! flag combination for skeleton mechanical machines */
	GameDriverMachineIsSkeletonMechanical    = GameDriverMachineIsSkeleton | GameDriverMachineMechanical | GameDriverMachineRequiresArtwork
};


OE_EXPORTED_CLASS
@interface GameDriver: NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *shortName;
@property (nonatomic, readonly) NSString *fullName;
@property (nonatomic, readonly, nullable) NSString *parent;
@property (nonatomic, readonly) GameDriverOptions flags;

@end

NS_ASSUME_NONNULL_END
