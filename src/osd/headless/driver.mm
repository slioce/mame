#import "driver+private.h"
#import "DriverList+Private.h"
#import <emu.h>
#import "../../frontend/mame/infoxml.h"

OE_STATIC_ASSERT(GameDriverMachineNoCocktail == MACHINE_NO_COCKTAIL);
OE_STATIC_ASSERT(GameDriverMachineIsBiosRoot == MACHINE_IS_BIOS_ROOT);
OE_STATIC_ASSERT(GameDriverMachineRequiresArtwork == MACHINE_REQUIRES_ARTWORK);
OE_STATIC_ASSERT(GameDriverMachineUnofficial == MACHINE_UNOFFICIAL);
OE_STATIC_ASSERT(GameDriverMachineNoSoundHw == MACHINE_NO_SOUND_HW);
OE_STATIC_ASSERT(GameDriverMachineMechanical == MACHINE_MECHANICAL);
OE_STATIC_ASSERT(GameDriverMachineIsIncomplete == MACHINE_IS_INCOMPLETE);
OE_STATIC_ASSERT(GameDriverMachineNotWorking == MACHINE_NOT_WORKING);
OE_STATIC_ASSERT(GameDriverMachineSupportsSave == MACHINE_SUPPORTS_SAVE);
OE_STATIC_ASSERT(GameDriverMachineUnemulatedProtection == MACHINE_UNEMULATED_PROTECTION);
OE_STATIC_ASSERT(GameDriverMachineWrongColors == MACHINE_WRONG_COLORS);
OE_STATIC_ASSERT(GameDriverMachineImperfectColors == MACHINE_IMPERFECT_COLORS);
OE_STATIC_ASSERT(GameDriverMachineImperfectGraphics == MACHINE_IMPERFECT_GRAPHICS);
OE_STATIC_ASSERT(GameDriverMachineNoSound == MACHINE_NO_SOUND);
OE_STATIC_ASSERT(GameDriverMachineImperfectSound == MACHINE_IMPERFECT_SOUND);
OE_STATIC_ASSERT(GameDriverMachineImperfectControls == MACHINE_IMPERFECT_CONTROLS);
OE_STATIC_ASSERT(GameDriverMachineNoDeviceMicrophone == MACHINE_NODEVICE_MICROPHONE);
OE_STATIC_ASSERT(GameDriverMachineNoDevicePrinter == MACHINE_NODEVICE_PRINTER);
OE_STATIC_ASSERT(GameDriverMachineNoDeviceLan == MACHINE_NODEVICE_LAN);
OE_STATIC_ASSERT(GameDriverMachineImperfectTiming == MACHINE_IMPERFECT_TIMING);

@implementation GameDriver {
	game_driver const *_driver;
	NSString *_name;
	NSString *_shortName;
	NSString *_fullName;
	NSString *_parent;
}

- (instancetype)initWithGameDriver:(game_driver const *)driver
{
	if ((self = [super init]))
	{
		_driver = driver;
	}
	return self;
}

- (NSString *)name
{
	return _name ?: (_name = NSSTRING_NO_COPY(_driver->name));
}

- (NSString *)shortName
{
	return _shortName ?: (_shortName = NSSTRING_NO_COPY(_driver->type.shortname()));
}

- (NSString *)fullName
{
	return _fullName ?: (_fullName = NSSTRING_NO_COPY(_driver->type.fullname()));
}

- (NSString * __nullable)parent
{
	if (_driver->parent == nullptr) return nil;

	return _parent ?: (_parent = NSSTRING_NO_COPY(_driver->parent));
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ (%@)", self.fullName, self.name];
}

- (GameDriverOptions)flags
{
	// Since MAME 0.260 game_driver::flags only carries the system flags;
	// emulation status lives on the driver's device type. Rebuild the
	// combined MACHINE_* bit field the frontend expects.
	u64 result = u64(_driver->flags);

	auto const &type = _driver->type;
	auto const emulation = type.emulation_flags();
	auto const unemulated = type.unemulated_features();
	auto const imperfect = type.imperfect_features();

	if (emulation & device_t::flags::NOT_WORKING)
		result |= MACHINE_NOT_WORKING;
	if (!(emulation & device_t::flags::SAVE_UNSUPPORTED))
		result |= MACHINE_SUPPORTS_SAVE;

	if (unemulated & device_t::feature::PALETTE)
		result |= MACHINE_WRONG_COLORS;
	if (unemulated & device_t::feature::SOUND)
		result |= MACHINE_NO_SOUND;
	if (unemulated & device_t::feature::MICROPHONE)
		result |= MACHINE_NODEVICE_MICROPHONE;
	if (unemulated & device_t::feature::PRINTER)
		result |= MACHINE_NODEVICE_PRINTER;
	if (unemulated & device_t::feature::LAN)
		result |= MACHINE_NODEVICE_LAN;

	if (imperfect & device_t::feature::PROTECTION)
		result |= MACHINE_UNEMULATED_PROTECTION;
	if (imperfect & device_t::feature::PALETTE)
		result |= MACHINE_IMPERFECT_COLORS;
	if (imperfect & device_t::feature::GRAPHICS)
		result |= MACHINE_IMPERFECT_GRAPHICS;
	if (imperfect & device_t::feature::SOUND)
		result |= MACHINE_IMPERFECT_SOUND;
	if (imperfect & device_t::feature::CONTROLS)
		result |= MACHINE_IMPERFECT_CONTROLS;
	if (imperfect & device_t::feature::TIMING)
		result |= MACHINE_IMPERFECT_TIMING;

	return static_cast<GameDriverOptions>(result);
}

- (void)dealloc
{
	NSLog(@"%@: dealloc", NSStringFromClass(self.class));
}

@end

#import "drivenum.h"

static GameDriver * __strong * s_drivers_sorted;

@implementation DriverList {
	CFArrayRef _items;
}

+ (DriverList *)shared
{
	static DriverList *obj;

	static dispatch_once_t once;
	dispatch_once(&once, ^{
		s_drivers_sorted = static_cast<GameDriver * __strong *>(calloc(driver_list::total(), sizeof(GameDriver *)));
		for (size_t i = 0; i < driver_list::total(); i++)
		{
			s_drivers_sorted[i] = [[GameDriver alloc] initWithGameDriver:&driver_list::driver(i)];
		}

		obj = [DriverList new];
		obj->_items = CFArrayCreate(kCFAllocatorDefault, (const void * *)(void *)s_drivers_sorted, static_cast<CFIndex>(driver_list::total()), &kCFTypeArrayCallBacks);
	});

	return obj;
}

- (NSArray<GameDriver *> *)allDrivers
{
	return (__bridge NSArray *)_items;
}

- (GameDriver *)findWithName:(NSString *)name
{
	auto index = driver_list::find(name.UTF8String);
	if (index == -1) {
		return nil;
	}

	return s_drivers_sorted[index];
}

@end
