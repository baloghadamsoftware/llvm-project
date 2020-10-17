//===- TestLoopMapping.cpp --- Parametric loop mapping pass ---------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements a pass to parametrically map scf.for loops to virtual
// processing element dimensions.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/SCF/SCF.h"
#include "mlir/IR/Builders.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/LoopUtils.h"
#include "mlir/Transforms/Passes.h"

#include "llvm/ADT/SetVector.h"

using namespace mlir;

namespace {
class TestLoopMappingPass
    : public PassWrapper<TestLoopMappingPass, FunctionPass> {
public:
  explicit TestLoopMappingPass() {}

  void runOnFunction() override {
    FuncOp func = getFunction();

    // SSA values for the transformation are created out of thin air by
    // unregistered "new_processor_id_and_range" operations. This is enough to
    // emulate mapping conditions.
    SmallVector<Value, 8> processorIds, numProcessors;
    func.walk([&processorIds, &numProcessors](Operation *op) {
      if (op->getName().getStringRef() != "new_processor_id_and_range")
        return;
      processorIds.push_back(op->getResult(0));
      numProcessors.push_back(op->getResult(1));
    });

    func.walk([&processorIds, &numProcessors](scf::ForOp op) {
      // Ignore nested loops.
      if (op.getParentRegion()->getParentOfType<scf::ForOp>())
        return;
      mapLoopToProcessorIds(op, processorIds, numProcessors);
    });
  }
};
} // end namespace

namespace mlir {
void registerTestLoopMappingPass() {
  PassRegistration<TestLoopMappingPass>(
      "test-mapping-to-processing-elements",
      "test mapping a single loop on a virtual processor grid");
}
} // namespace mlir
